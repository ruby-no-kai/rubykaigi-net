#!/usr/bin/env ruby
# Query the rknet Prometheus through the Kubernetes API service proxy, which needs only kubectl access.
#
# Usage:
#   prom.rb query 'PROMQL' [--time RFC3339|UNIX]
#   prom.rb range 'PROMQL' [--since 1h] [--step 60]
#   prom.rb alerts
#   prom.rb am-alerts                # Alertmanager, with silence and inhibition state
#   prom.rb names [REGEXP]           # metric names
#   prom.rb labels METRIC            # label values seen on a metric's current series
#   prom.rb --raw ...                # print the API response as is
require 'cgi'
require 'json'
require 'open3'
require 'optparse'
require 'time'

CONTEXT = 'arn:aws:eks:ap-northeast-1:005216166247:cluster/rknet'
PROM = '/api/v1/namespaces/default/services/prometheus-operated:9090/proxy'
ALERTMANAGER = '/api/v1/namespaces/default/services/alertmanager-operated:9093/proxy'

def get(path, params = {})
  query = params.map { |k, v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')
  url = query.empty? ? path : "#{path}?#{query}"
  out, err, status = Open3.capture3('kubectl', '--context', CONTEXT, 'get', '--raw', url)
  raise "kubectl get --raw #{url} failed: #{err}" unless status.success?
  JSON.parse(out)
end

def duration(str)
  m = str.match(/\A(\d+)([smhd])\z/) or raise ArgumentError, "bad duration: #{str}"
  m[1].to_i * {'s' => 1, 'm' => 60, 'h' => 3600, 'd' => 86400}.fetch(m[2])
end

def labels_of(metric)
  name = metric['__name__']
  rest = metric.except('__name__').map { |k, v| "#{k}=#{v.inspect}" }.join(', ')
  "#{name}{#{rest}}"
end

def fmt_time(ts) = Time.at(ts.to_f).localtime.strftime('%m-%d %H:%M:%S')

raw = false
opts = {since: '1h', step: '60', time: nil}
parser = OptionParser.new do |o|
  o.on('--raw') { raw = true }
  o.on('--since DURATION') { opts[:since] = _1 }
  o.on('--step SECONDS') { opts[:step] = _1 }
  o.on('--time TIME') { opts[:time] = _1 }
end
args = parser.parse(ARGV)
command = args.shift or abort(parser.banner + "\nsee the header of #{__FILE__}")

resp = case command
when 'query'
  get("#{PROM}/api/v1/query", {query: args.fetch(0), time: opts[:time]}.compact)
when 'range'
  now = Time.now.to_i
  get("#{PROM}/api/v1/query_range", query: args.fetch(0), start: now - duration(opts[:since]), end: now, step: opts[:step])
when 'alerts'
  get("#{PROM}/api/v1/alerts")
when 'am-alerts'
  get("#{ALERTMANAGER}/api/v2/alerts")
when 'names'
  get("#{PROM}/api/v1/label/__name__/values")
when 'labels'
  get("#{PROM}/api/v1/series", 'match[]' => args.fetch(0), start: Time.now.to_i - 300)
else
  abort "unknown command: #{command}"
end

if raw
  puts JSON.generate(resp)
  exit
end

case command
when 'query'
  data = resp.fetch('data')
  case data.fetch('resultType')
  when 'vector'
    data.fetch('result').each { |r| puts "#{labels_of(r.fetch('metric'))} #{r.fetch('value')[1]}" }
  else
    puts JSON.generate(data.fetch('result'))
  end
  (resp['warnings'] || []).each { warn "warning: #{_1}" }
when 'range'
  resp.fetch('data').fetch('result').each do |r|
    puts labels_of(r.fetch('metric'))
    puts '  ' + r.fetch('values').map { |ts, v| "#{fmt_time(ts)}=#{v}" }.join(' ')
  end
when 'alerts'
  resp.fetch('data').fetch('alerts').each do |a|
    l = a.fetch('labels')
    puts [a.fetch('state'), a['activeAt'], l['severity'], l['alertname'], a.dig('annotations', 'summary')].join("\t")
  end
when 'am-alerts'
  resp.each do |a|
    st = a.fetch('status')
    puts [st.fetch('state'), a['startsAt'], a.dig('labels', 'severity'), a.dig('labels', 'alertname'), a.dig('annotations', 'summary')].join("\t")
  end
when 'names'
  re = args[0] ? Regexp.new(args[0], Regexp::IGNORECASE) : nil
  names = resp.fetch('data')
  puts(re ? names.grep(re) : names)
when 'labels'
  values = Hash.new { |h, k| h[k] = Set.new }
  resp.fetch('data').each { |s| s.each { |k, v| values[k] << v } }
  values.except('__name__').sort.each { |k, vs| puts "#{k} (#{vs.size}): #{vs.to_a.sort.first(20).join(' ')}" }
end
