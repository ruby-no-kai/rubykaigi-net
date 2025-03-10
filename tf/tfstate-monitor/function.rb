require 'aws-sdk-s3'
require 'aws-sdk-costexplorer'
require 'json'
require 'time'
require 'logger'
require 'cgi'
$stdout.sync = true

module TfstateMonitor
  COST_DAYS = 5

  ACCOUNT_ID = Aws::STS::Client.new.get_caller_identity.account
  S3_BUCKET = ENV.fetch('S3_BUCKET', 'rk-infra')
  S3_PREFIX = ENV.fetch('S3_PREFIX', 'terraform/')

  OUTPUT_S3_BUCKET = ENV.fetch('OUTPUT_S3_BUCKET', 'rubykaigi-dot-net')
  OUTPUT_S3_KEY = ENV.fetch('OUTPUT_S3_KEY', 'tfstate-monitor')

  @s3 = Aws::S3::Client.new(logger: Logger.new($stdout))
  @ce = Aws::CostExplorer::Client.new(region: 'us-east-1', logger: Logger.new($stdout))

  TagPair = Data.define(:project, :component)
  Status = Data.define(:key, :tfstate) do
    # remove prefix and .tfstate extension
    def name
      key[S3_PREFIX.size..-9]
    end
    
    def num_resources
      tfstate.fetch('resources', []).reject do |resource|
        resource['mode'] == 'data'
      end.size
    end

    def project_and_component_tag_pairs
      tfstate.fetch('resources', []).flat_map do |resource|
        next [] if resource['mode'] == 'data'
        resource['instances'].map do |instance|
          tags = (instance.dig('attributes', 'tags_all') || {}).merge(instance.dig('attributes', 'tags') || {})
          TagPair.new(
            project: tags['Project'],
            component: [tags['Component']].compact,
          )
        end.select do |tag_pair|
          tag_pair.project
        end
      end.uniq.sort_by { [_1.project,_1.component || ''] }
    end

    def component_tags_per_project
      project_and_component_tag_pairs.group_by(&:project).transform_values do |tag_pairs|
        tag_pairs.flat_map(&:component).uniq.sort
      end.map do |project, component|
        TagPair.new(project:, component:)
      end
    end
  end

  def self.cost(status:, now: Time.now.utc)
    cur = @ce.get_cost_and_usage(
      time_period: {
        start: (now - (86400*(COST_DAYS+1))).strftime('%Y-%m-%d'),
        end: now.strftime('%Y-%m-%d'),
      },
      granularity: 'DAILY',
      metrics: ['NetAmortizedCost'],
      group_by: [],
      filter: {
        and: [
          {
            dimensions: {
              key: 'LINKED_ACCOUNT',
              values: [ACCOUNT_ID],
              match_options: ['EQUALS'],
            },
          },
          {
            or: status.component_tags_per_project.map do |tag_pair|
              {
                and: [
                  {
                    tags: {
                      key: 'Project',
                      values: [tag_pair.project],
                    },
                  },
                  {
                    tags: {
                      key: 'Component',
                      values: tag_pair.component,
                    }.then { _1[:values].empty? ? _1.slice(:key).merge(match_options: %w(ABSENT)) : _1 },
                  },
                ].reject { _1[:tags][:values] && _1[:tags][:values].empty? },
              }.then { _1[:and].size == 1 ? _1[:and].first : _1 }
            end
          }.then { case _1[:or].size; when 0; nil; when 1; _1[:or].first; else _1; end },
        ].compact.tap { return 0 if _1.size == 1 },
      }.then { _1[:and].size == 1 ? _1[:and].first : _1 }.tap { puts(JSON.generate(key: status.key, filter: _1)) },
    )
    cur.results_by_time[0..-2].map(&:total).map do |total|
      total.fetch('NetAmortizedCost').amount.to_f
    end.inject(:+) / COST_DAYS
  end

  RenderedStatus = Data.define(
    :key,
    :name,
    :num_resources,
    :cost,
    :tag_pairs,
    :ts,
  ) do
    def as_json
      to_h
    end
  end

  def self.render_status(status)
    RenderedStatus.new(
      key: status.key,
      name: status.name,
      num_resources: status.num_resources,
      cost: cost(status: status),
      tag_pairs: status.project_and_component_tag_pairs.map(&:to_h),
      ts: Time.now.to_i,
    )
  end


  def self.render_html(statuses:)
    StringIO.new(<<~EOF, 'r') # use stringio to avoid logging the content
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="utf-8">
        <title>tfstate-monitor</title>
        <style>
          body {
            font-family: sans-serif;
          }
          #list .cell-cost {
            min-width: 70px;
            text-align: right;
          }
          #list .cell-nonzero, #list .cell-zero {
            min-width: 50px;
            text-align: right;
          }
          #list .cell-nonzero {
            background-color: #d1f542;
          }
          #list .cell-zero {
            background-color: #fc6262;
          }
          #footer {
            font-size: 90%;
          }

          .d-none {
            display: none;
          }
        </style>
      </head>
      <body data-cache="#{CGI.escape_html(JSON.generate(statuses.transform_values(&:as_json)))}">
        <header><h1>tfstate-monitor</h1></header>

        <main>
        <table id="list">
        <tbody>
          #{
            statuses.each_value.sort_by(&:name).map do |status|
              <<~EOR
                <tr>
                  <td class="cell-name">
                    #{CGI.escape_html(status.name)}
                    <dl class="d-none tag-pairs">
                      #{
                        status.tag_pairs.map do |tag_pair_v|
                          tag_pair = TagPair.new(**tag_pair_v)
                          <<~EOR
                            <dt>#{CGI.escape_html(tag_pair.project)}</dt>
                            <dd>#{CGI.escape_html(tag_pair.component&.join(', ') || '')}</dd>
                          EOR
                        end.join("\n")
                      }
                    </dl>
                  </td>
                  <td class="#{status.num_resources.zero? ? 'cell-zero' : 'cell-nonzero'}">#{status.num_resources}</td>
                  <td class="cell-cost">#{"%.2f" % [status.cost]}</td>
                  <td class="cell-cost">#{"%.2f" % [status.cost * 30]}</td>
                </tr>
              EOR
            end.join("\n")
          }
        </tbody>
        </table>
        </main>

        <footer id='footer'>
          <p><small>Last updated at #{Time.now.xmlschema}</small><p>
          <p><small>Source: <a href="https://github.com/ruby-no-kai/rubykaigi-net/tree/master/tf/tfstate-monitor">rubykaigi-net//tf/tfstate-monitor</a></small></p>
        </footer>
      </body>
      </html>
    EOF
  end

  def self.handler(event:, context:)
    p(event:)

    cache = event['no_cache'] ? {} : begin
      cache_obj = @s3.get_object(bucket: OUTPUT_S3_BUCKET, key: OUTPUT_S3_KEY)
      j = JSON.parse(CGI.unescape_html(cache_obj.body.read.match(/data-cache="([^"]+)"/)&.[](1)))
      j.transform_values { RenderedStatus.new(**_1) }
    rescue ArgumentError, Aws::S3::Errors::NoSuchKey
      {}
    end

    # find key from EventBridge S3 notification or manual "key" parameter, othewise list all tfstate files
    keys = event.dig('detail', 'object', 'key') || event['key'] \
      || @s3.list_objects_v2(bucket: S3_BUCKET, prefix: S3_PREFIX).flat_map(&:contents).filter_map do |object|
      next unless object.key.end_with?('.tfstate')
      object.key
    end

    statuses = [*keys].map do |key|
      tfstate_json = @s3.get_object(bucket: S3_BUCKET, key:).body.read
      tfstate = JSON.parse(tfstate_json)
      Status.new(key:, tfstate:)
    end.sort_by(&:key)
    rendered_statuses = cache.merge(statuses.map { [_1.key, render_status(_1)] }.to_h)

    body = render_html(statuses: rendered_statuses)
    @s3.put_object(
      bucket: OUTPUT_S3_BUCKET,
      key: OUTPUT_S3_KEY,
      body:,
      content_type: 'text/html',
      if_match: cache_obj&.etag,
    )
  end
end

def handler(event:, context:)
  TfstateMonitor.handler(event:, context:)
end
if $0 == __FILE__
  event = ARGV[0] ? {'key' => ARGV[0]} : {}
  handler(event:, context: {})
end
