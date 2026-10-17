#!/usr/bin/env ruby
# Watches Alertmanager and prints one line per new active alert, per resolved or suppressed alert, and per API outage.
require 'json'
require 'open3'
require 'optparse'
require 'time'

ALERTS_PATH = '/api/v1/namespaces/default/services/alertmanager-operated:9093/proxy/api/v2/alerts'.freeze
JST = '+09:00'.freeze

options = {
  context: 'arn:aws:eks:ap-northeast-1:005216166247:cluster/rknet',
  interval: 20,
  once: false,
  fixture_dir: ENV['AM_WATCH_FIXTURE_DIR']
}
OptionParser.new do |o|
  o.on('--interval N', Integer) { |v| options[:interval] = v }
  o.on('--context CTX') { |v| options[:context] = v }
  o.on('--once') { options[:once] = true }
  o.on('--fixture-dir DIR', 'sequential JSON files (or an *.error file) instead of kubectl') { |v| options[:fixture_dir] = v }
end.parse!

STDOUT.sync = true

class FetchError < StandardError; end

class Source
  def initialize(context:, fixture_dir:)
    @context = context
    @fixture_dir = fixture_dir
    @index = 0
  end

  def alerts
    @fixture_dir ? fixture_alerts : kubectl_alerts
  end

  private

  def kubectl_alerts
    out, err, status = Open3.capture3('kubectl', '--context', @context, 'get', '--raw', ALERTS_PATH)
    raise FetchError, "kubectl failed: #{err.strip[0, 120]}" unless status.success?

    JSON.parse(out)
  rescue JSON::ParserError => e
    raise FetchError, "bad JSON: #{e.message[0, 80]}"
  end

  def fixture_alerts
    files = Dir.glob(File.join(@fixture_dir, '*')).sort
    file = files.fetch([@index, files.size - 1].min)
    @index += 1
    raise FetchError, File.read(file).strip if file.end_with?('.error')

    JSON.parse(File.read(file))
  end
end

def active?(alert)
  alert.fetch('status').fetch('state') == 'active'
end

def label(alert)
  labels = alert.fetch('labels')
  labels['instance'] || labels['job_name'] || labels['pod'] || labels['dst'] || labels['job'] || labels['namespace'] || '-'
end

def clip(text)
  text.to_s.gsub(/\s+/, ' ').strip[0, 160]
end

def stamp
  Time.now.getlocal(JST).strftime('%H:%M:%S')
end

def new_line(alert)
  labels = alert.fetch('labels')
  annotations = alert.fetch('annotations', {})
  detail = clip(annotations['summary'] || annotations['description'] || annotations['message'])
  "NEW #{stamp} #{labels.fetch('severity', '-')} #{labels.fetch('alertname')} #{label(alert)}: #{detail}"
end

def resolved_line(alert, suppressed)
  labels = alert.fetch('labels')
  "RESOLVED #{stamp} #{labels.fetch('alertname')} #{label(alert)}#{suppressed ? ' (silenced/inhibited)' : ''}"
end

# Returns [lines, new_known] where known maps fingerprint => alert for alerts that were active.
def diff(known, alerts)
  by_fp = alerts.to_h { |a| [a.fetch('fingerprint'), a] }
  lines = []
  by_fp.each do |fp, alert|
    lines << new_line(alert) if active?(alert) && !known.key?(fp)
  end
  known.each do |fp, alert|
    current = by_fp[fp]
    lines << resolved_line(alert, !current.nil?) if current.nil? || !active?(current)
  end
  [lines, by_fp.select { |_, a| active?(a) }]
end

source = Source.new(context: options.fetch(:context), fixture_dir: options[:fixture_dir])
known = nil
failing = false
backoff = options.fetch(:interval)

loop do
  begin
    alerts = source.alerts
    if failing
      puts "WATCH-OK #{stamp}"
      failing = false
    end
    backoff = options.fetch(:interval)
    if known.nil?
      known = alerts.select { |a| active?(a) }.to_h { |a| [a.fetch('fingerprint'), a] }
      names = known.values.map { |a| a.fetch('labels').fetch('alertname') }.tally.map { |n, c| c > 1 ? "#{n}x#{c}" : n }
      puts "BASELINE #{known.size} active: #{names.join(', ')}"
      if options.fetch(:once)
        known.each_value { |a| puts "  #{a.fetch('labels').fetch('severity', '-')} #{a.fetch('labels').fetch('alertname')} #{label(a)}" }
      end
    else
      lines, known = diff(known, alerts)
      lines.each { |l| puts l }
    end
  rescue FetchError => e
    unless failing
      puts "WATCH-ERROR #{stamp} #{e.message}"
      failing = true
    end
    backoff = [backoff * 2, 60].min
  end
  break if options.fetch(:once)

  sleep(options[:fixture_dir] ? 0 : backoff)
  break if options[:fixture_dir] && source.instance_variable_get(:@index) > Dir.glob(File.join(options[:fixture_dir], '*')).size
end
