require_relative './common'
require 'faraday'
require 'faraday/multipart'
require 'faraday/retry'
require 'stringio'
require 'time'

class Outbound
  include Common

  SqsRecord = Struct.new(:raw, :body)

  def perform
    (event['Records'] || []).each do |raw|
      r = SqsRecord.new(raw, JSON.parse(raw['body'] || '{}'))
      case r.body['kind']
      when 'webhook_payload'
        perform_webhook_payload(r)
      else
        raise "Unknown message: #{raw.inspect}"
      end
    end
  end

  def perform_webhook_payload(sqs_record)
    record = sqs_record.body

    puts(JSON.generate({log: 'perform_webhook_payload.start', sqs_record: sqs_record.raw}))

    payload = record.fetch('payload')
    id = payload.fetch('id')
    type = payload.fetch('type')

    if dynamodb_get("frontevent:#{id}", consistent_read: true)
      puts(JSON.generate({log: 'perform_webhook_payload.skip', message: 'Skip due to duplicate', event_id: id}))
      return
    end

    case type
    when 'outbound', 'out_reply'
      handle_event_outbound(payload, sqs_record)
    else
      raise "Unknown type: #{type}" 
    end

    dynamodb_update(pk: "frontevent:#{id}", sk: "frontevent:#{id}", processed_at: Time.now.xmlschema)
  end

  def handle_event_outbound(payload, sqs_record)
    event_url = payload.dig('_links', 'self')

    message = front.get("messages/#{payload.fetch('target').fetch('data').fetch('id')}").body

    if message.fetch('type') != 'tweet'
      puts(JSON.generate({log: 'handle_event_outbound.skip', message: 'Skip because message is not a tweet', event_url: event_url}))
      return
    end

    tweet_id = message.fetch('metadata').fetch('external_id')
    tweet = fixtweet.get("_/status/#{tweet_id}").body.fetch('tweet')

    parent = message.dig('_links', 'related', 'message_replied_to')&.then { |url| front.get(url).body }
    parent = nil if parent && parent.fetch('type') != 'tweet'

    # sanity check
    if parent && tweet['replying_to'].nil?
      raise "parent exists on Front but FixTweet returned no replying_to attribute, #{payload['id']}"
    end

    # if it is a reply, skip if a message is sent to other user (= if it is not a threading)
    if parent && tweet['replying_to'] != tweet.fetch('author').fetch('screen_name')
      puts(JSON.generate({log: 'handle_event_outbound.skip', message: 'Skip because message is a reply and not a threading', tweet: tweet, event_url: event_url}))
      return
    end

    # for threading, retrieve parent toot ID from DynamoDB
    in_reply_to_id = parent
      &.then { |d| d.fetch('metadata').fetch('external_id') }
      &.then { |parent_tweet_id|
        parent_tweet_record = dynamodb_get("tweet:#{parent_tweet_id}", consistent_read: true) or raise "parent_tweet_id not exists on DynamoDB, #{parent_tweet_id.inspect}, #{payload['id']}"
        parent_tweet_record['mastodon_status_id']
      }

    text = tweet.fetch('text')

    attachment_incompatible = tweet.dig('media', 'videos') || (tweet['poll'] && tweet.dig('media', 'photos'))
    if attachment_incompatible
      text += "\n\n… #{tweet.fetch('url')}"
    else
      # TODO: media.photos[].url
      media_ids = tweet.dig('media', 'photos')&.map do |tweet_photo|
        upload_url_to_mastodon(tweet_photo.fetch('url'))
      end

      poll = tweet['poll']&.then do |tweet_poll|
        {
          expires_in: Time.xmlschema(tweet_poll.fetch('ends_at')) - Time.now,
          multiple: false,
          hide_totals: false,
          options: tweet_poll.fetch('choices').map { |choice| choice.fetch('label') },
        }
      end
    end

    outgoing_data = begin
      {
        status: text,
        in_reply_to_id: in_reply_to_id,
        language: text.match?(/[\u3040-\u309f]/) ? 'ja' : 'en', # hiragana
        media_ids: media_ids,
        poll: poll,
      }
    end
    puts(JSON.generate({log: 'handle_event_outbound.post', outgoing_data: outgoing_data, tweet: tweet, event_url: event_url}))
    resp = if doit?
      mastodon.post('api/v1/statuses', outgoing_data, {
        'Idempotency-Key' => sqs_record.raw&.dig('messageId'),
      }).body
    else
      {"id" => "[DUMMY]"}
    end

    # Save Tweet/Toot association on DynamoDB
    dynamodb_update(pk: "tweet:#{tweet_id}", sk: "tweet:#{tweet_id}", mastodon_status_id: resp.fetch('id'), tweet_id: tweet_id)
    dynamodb_update(pk: "mastodon:#{resp.fetch('id')}", sk: "mastodon:#{resp.fetch('id')}", mastodon_status_id: resp.fetch('id'), tweet_id: tweet_id)
  end

  def upload_url_to_mastodon(url)
    puts(JSON.generate({log: 'upload_url_to_mastodon.begin', url: url}))
    # (Assume we'll not get large response)
    image_resp = Faraday.new do |builder|
      builder.request :retry, RETRY_OPTIONS
      builder.response :raise_error
      builder.adapter :net_http
    end.get(url)

    resp = if doit?
      mastodon.post('api/v2/media', {
        file: Faraday::Multipart::FilePart.new(StringIO.new(image_resp.body), image_resp.headers['content-type'], url.sub(/^.+\//, '')),
        # TODO: alt text
      }, { 'Content-Type' => 'multipart/form-data' }).body
    else
      { "id" => "[DUMMY]" }
    end
    puts(JSON.generate({log: 'upload_url_to_mastodon.done', url: url, id: resp['id']}))
    resp.fetch('id')
  end

  def dynamodb_get(pk, sk = pk, consistent_read: false)
    dynamodb.query(
      table_name: dynamodb_table,
      consistent_read: consistent_read,
      key_condition_expression: "pk = :pk and sk = :sk",
      expression_attribute_values: {":pk" => pk, ":sk" => sk},
      limit: 1,
    ).items[0]
  end

  def dynamodb_update(data)
    puts(JSON.generate({log: 'dynamodb_update', data: data}))
    return unless doit?
    keys = data.keys.reject { |k| k == :pk || k == :sk }
    dynamodb.update_item(
      table_name: dynamodb_table,
      return_values: "ALL_NEW",
      key: {"pk" => data.fetch(:pk), "sk" => data.fetch(:sk)},
      update_expression: <<~EOS,
        SET #{keys.map { |k| "##{k} = :#{k}" }.join(', ')}
      EOS
      expression_attribute_names:  keys.map { |k| ["##{k}", k.to_s] }.to_h,
      expression_attribute_values:  keys.map { |k| [":#{k}", data.fetch(k)] }.to_h,
    )
  end

  USER_AGENT = 'RubyKaigi-FrontWebhookTweetToMastodon (+https://rubykaigi.org)'
  RETRY_OPTIONS = { max: 10, interval: 0.7, interval_randomness: 0.5, backoff_factor: 2 }

  def mastodon
    @mastodon ||= Faraday.new(url: secret.fetch(:mastodon_url), headers: {'User-Agent' => USER_AGENT}) do |builder|
      builder.request :retry, RETRY_OPTIONS
      builder.request :authorization, 'Bearer', secret.fetch(:mastodon_access_token)
      builder.request :json
      builder.request :multipart
      builder.response :json
      builder.response :raise_error
      builder.adapter :net_http
    end
  end

  def front
    @front ||= Faraday.new(url: 'https://api2.frontapp.com', headers: {'User-Agent' => USER_AGENT}) do |builder|
      builder.request :retry, RETRY_OPTIONS
      builder.request :authorization, 'Bearer', secret.fetch(:front_access_token)
      builder.request :url_encoded
      builder.response :json
      builder.response :raise_error
      builder.adapter :net_http
    end
  end

  def fixtweet
    @fixtweet ||= Faraday.new(url: 'https://api.fxtwitter.com', headers: {'User-Agent' => USER_AGENT}) do |builder|
      builder.request :retry, RETRY_OPTIONS
      builder.request :url_encoded
      builder.response :raise_error
      builder.response :json
      builder.adapter :net_http
    end
  end
end

def handler(event:, context:)
  Outbound.new(event, context).perform
end

if $0 == __FILE__
  p Outbound.new(nil, nil).perform_webhook_payload(Outbound::SqsRecord.new(nil, JSON.parse(ARGF.read)))
end
