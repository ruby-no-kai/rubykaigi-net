#!/usr/bin/env ruby
# Failed and retried frame ratios, tx rate and clients per 5 GHz radio over 5 minutes. Usage: radio_ratios.rb [AP_NAME_REGEX, default ^ap-lb1-.*]
require 'json'
require 'open3'

REPO = `git rev-parse --show-toplevel`.strip
PROM = File.join(REPO, '.claude/skills/rknet-observability/scripts/prom.rb')
PATTERN = ARGV.fetch(0, '^ap-lb1-.*')

def prom(q)
  out, = Open3.capture2('ruby', PROM, '--raw', 'query', q, chdir: REPO)
  (JSON.parse(out).dig('data', 'result') || []).to_h { |r| [r['metric']['bsnAPName'], r['value'][1].to_f] }
rescue JSON::ParserError
  {}
end

sel = %({bsnAPName=~"#{PATTERN}",bsnAPIfSlotId="1"})
tx = prom("rate(bsnAPIfDot11TransmittedFrameCount#{sel}[5m])")
fail = prom("rate(bsnAPIfDot11FailedCount#{sel}[5m])")
retry_ = prom("rate(bsnAPIfDot11RetryCount#{sel}[5m])")
users = prom("bsnApIfNoOfUsers#{sel}")
level = prom("bsnAPIfPhyTxPowerLevel#{sel}")

puts "== #{Time.now.strftime('%H:%M:%S')} lobby radios (slot 1), 5 min window"
puts format('%-10s %6s %8s %7s %7s %5s', 'AP', 'users', 'tx/s', 'fail%', 'retry%', 'level')
tx.keys.sort.each do |ap|
  t = tx.fetch(ap)
  f = t > 50 ? format('%.1f', 100 * fail.fetch(ap, 0) / t) : 'n/a'
  r = t > 50 ? format('%.1f', 100 * retry_.fetch(ap, 0) / t) : 'n/a'
  puts format('%-10s %6d %8.0f %7s %7s %5s', ap, users.fetch(ap, 0), t, f, r, level.fetch(ap, 0).to_i)
end
