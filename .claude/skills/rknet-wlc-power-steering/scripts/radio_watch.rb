#!/usr/bin/env ruby
# Watches Prometheus for 5 GHz radios near their client cap and prints one line per state change.
# Lines: BASELINE, HOT, COOL, FAIL, FAIL-CLEAR, WATCH-ERROR, WATCH-OK. SNMP lags the WLC, so confirm every HOT with slot_counts.sh.
require 'json'
require 'open3'
require 'optparse'
require 'uri'

PROM_PATH = '/api/v1/namespaces/default/services/prometheus-operated:9090/proxy/api/v1/query'.freeze
JST = '+09:00'.freeze

options = {
  context: 'arn:aws:eks:ap-northeast-1:005216166247:cluster/rknet',
  interval: 60,
  cap: 100,
  # rk-5g-med (AP group rk-med) allowed 200 clients per radio at KoR26; check `show rf-profile details` per event.
  caps: { /\Aap-(lb0|int|off)-/ => 200 },
  hot: 0.9,
  clear: 0.8,
  fail_clients: nil,
  fail_ratio: 0.3,
  fail_min_tx: 200,
  once: false
}
cap_for_args = {}
OptionParser.new do |o|
  o.on('--interval N', Integer) { |v| options[:interval] = v }
  o.on('--context CTX') { |v| options[:context] = v }
  o.on('--cap N', Integer, 'default per-radio client cap (100)') { |v| options[:cap] = v }
  o.on('--cap-for REGEX=N', 'cap for AP names matching REGEX; replaces the built-in list') do |v|
    re, n = v.split('=', 2)
    cap_for_args[Regexp.new(re)] = Integer(n)
  end
  o.on('--hot F', Float, 'HOT at this fraction of the cap (0.9)') { |v| options[:hot] = v }
  o.on('--clear F', Float, 'COOL below this fraction of the cap (0.8)') { |v| options[:clear] = v }
  o.on('--fail-clients N', Integer, 'enable FAIL lines for radios with at least N clients') { |v| options[:fail_clients] = v }
  o.on('--fail-ratio F', Float) { |v| options[:fail_ratio] = v }
  o.on('--once') { options[:once] = true }
end.parse!
options[:caps] = cap_for_args unless cap_for_args.empty?

STDOUT.sync = true

class FetchError < StandardError; end

def query(context, promql)
  url = "#{PROM_PATH}?query=#{URI.encode_www_form_component(promql)}"
  out, err, status = Open3.capture3('kubectl', '--context', context, 'get', '--raw', url)
  raise FetchError, "kubectl failed: #{err.strip[0, 120]}" unless status.success?

  JSON.parse(out).dig('data', 'result').to_h { |r| [r.dig('metric', 'bsnAPName'), r['value'][1].to_f] }
rescue JSON::ParserError => e
  raise FetchError, "bad JSON: #{e.message[0, 80]}"
end

def stamp
  Time.now.getlocal(JST).strftime('%H:%M:%S')
end

def cap_for(ap, options)
  options.fetch(:caps).find { |re, _| re.match?(ap) }&.last || options.fetch(:cap)
end

# Slot 1 is the 5 GHz radio.
USERS = 'sum by (bsnAPName) (bsnApIfNoOfUsers{bsnAPIfSlotId="1"})'.freeze
TX = 'sum by (bsnAPName) (rate(bsnAPIfDot11TransmittedFrameCount{bsnAPIfSlotId="1"}[5m]))'.freeze
FAILED = 'sum by (bsnAPName) (rate(bsnAPIfDot11FailedCount{bsnAPIfSlotId="1"}[5m]))'.freeze

hot = {}
fail = {}
failing = false
baseline = true

loop do
  begin
    users = query(options.fetch(:context), USERS)
    tx = options[:fail_clients] ? query(options.fetch(:context), TX) : {}
    failed = options[:fail_clients] ? query(options.fetch(:context), FAILED) : {}
    puts "WATCH-OK #{stamp}" if failing
    failing = false

    events = []
    users.each do |ap, n|
      cap = cap_for(ap, options)
      if n >= cap * options.fetch(:hot) && !hot[ap]
        hot[ap] = true
        events << "HOT #{stamp} #{ap} #{n.to_i}/#{cap} clients"
      elsif hot[ap] && n < cap * options.fetch(:clear)
        hot.delete(ap)
        events << "COOL #{stamp} #{ap} #{n.to_i}/#{cap} clients"
      end
      next unless options[:fail_clients]

      t = tx[ap].to_f
      ratio = t >= options.fetch(:fail_min_tx) ? failed[ap].to_f / t : 0.0
      bad = n >= options[:fail_clients] && ratio >= options.fetch(:fail_ratio)
      if bad && !fail[ap]
        fail[ap] = true
        events << "FAIL #{stamp} #{ap} #{n.to_i} clients, tx fail #{(ratio * 100).round}% of #{t.round}/s"
      elsif fail[ap] && !bad
        fail.delete(ap)
        events << "FAIL-CLEAR #{stamp} #{ap} #{n.to_i} clients, tx fail #{(ratio * 100).round}%"
      end
    end

    if baseline
      puts "BASELINE #{stamp} #{users.size} radios, hot: #{hot.keys.sort.join(', ').then { _1.empty? ? 'none' : _1 }}"
      baseline = false
    else
      events.each { puts _1 }
    end
  rescue FetchError => e
    puts "WATCH-ERROR #{stamp} #{e.message}" unless failing
    failing = true
  end
  break if options.fetch(:once)

  sleep options.fetch(:interval)
end
