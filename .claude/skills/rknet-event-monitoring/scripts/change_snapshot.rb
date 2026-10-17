#!/usr/bin/env ruby
# After-change sample for a Tx power or RF change: dBm per radio, clients per area, busiest radios with fail ratio, cap rejects since the apply time.
# Usage: change_snapshot.rb APPLIED_HH:MM[:SS] [AP_REGEX=^ap-]   (needs an open wlc-01.venue ssh-cli session; LOG_GROUP overrides /rk26net/syslog)
require 'json'
require 'open3'
require 'time'

REPO = `git rev-parse --show-toplevel`.strip
PROM = File.join(REPO, '.claude/skills/rknet-observability/scripts/prom.rb')
APPLIED = Time.parse("#{Time.now.strftime('%Y-%m-%d')} #{ARGV.fetch(0)} +0900")
WATCH = Regexp.new(ARGV.fetch(1, '^ap-'))

def sh(*cmd) = Open3.capture2(*cmd, chdir: REPO).first

def prom(q)
  j = JSON.parse(sh('ruby', PROM, '--raw', 'query', q))
  (j.dig('data', 'result') || []).to_h { |r| [r['metric']['bsnAPName'], r['value'][1].to_f] }
rescue JSON::ParserError
  {}
end

radio = {}
# Columns: AP, MAC, slot, admin, oper, channel, level/levels (dBm). A `*` before the level marks TPC-managed; without it the level is static.
sh('ruby', 'misc/ssh_cli.rb', '-s', 'wlc-01.venue', 'run', 'show advanced 802.11a summary').each_line do |l|
  next unless l =~ /^(ap-\S+)\s+\S+\s+1\s+\S+\s+\S+\s+(\d+)\*?\s+(\*?)(\d+)\/(\d+)\s+\(\s*(-?\d+) dBm\)/

  radio[$1] = { ch: $2.to_i, level: "#{$4}/#{$5}#{$3.empty? ? 's' : ''}", dbm: $6.to_i }
end
users = prom('bsnApIfNoOfUsers{bsnAPIfSlotId="1"}')
tx = prom('rate(bsnAPIfDot11TransmittedFrameCount{bsnAPIfSlotId="1"}[5m])')
fail = prom('rate(bsnAPIfDot11FailedCount{bsnAPIfSlotId="1"}[5m])')

now = Time.now
puts "== #{now.strftime('%H:%M:%S')} JST, #{((now - APPLIED) / 60).round(1)} min after #{APPLIED.strftime('%H:%M:%S')}; radios parsed: #{radio.size}"
puts '5 GHz dBm distribution: ' + radio.values.group_by { _1[:dbm] }.transform_values(&:size).sort.reverse.map { |d, n| "#{d}=#{n}" }.join(' ')

area = Hash.new(0)
users.each { |ap, n| area[ap[/^ap-(.+?)-/, 1].to_s] += n.to_i }
puts 'slot-1 clients by area: ' + area.sort_by { -_2 }.map { |a, n| "#{a}=#{n}" }.join(' ') + "  total=#{area.values.sum}"

puts 'radios matching watch regex, busiest first (ap ch level dBm clients tx/s fail%):'
users.select { |ap, _| WATCH.match?(ap) }.sort_by { -_2 }.first(15).each do |ap, n|
  r = radio.fetch(ap, {})
  t = tx[ap].to_f
  f = t > 100 ? format('%.1f%%', 100 * fail[ap].to_f / t) : 'n/a'
  puts format('  %-10s ch%-4s %-4s %4s dBm %4d %6.0f %s', ap, r[:ch], r[:level], r[:dbm], n, t, f)
end

out, status = Open3.capture2('aws', 'logs', 'filter-log-events', '--region', 'ap-northeast-1', '--log-group-name', ENV.fetch('LOG_GROUP', '/rk26net/syslog'),
                             '--log-stream-name-prefix', 'wlc-01', '--filter-pattern', '"Maximum Client Limit Reached"',
                             '--start-time', ((APPLIED.to_i - 600) * 1000).to_s, '--query', 'events[].timestamp', '--output', 'json')
abort 'aws logs failed; cap rejects unknown' unless status.success?
ts = JSON.parse(out).map { Time.at(_1 / 1000).getlocal('+09:00') }
before, after = ts.partition { _1 < APPLIED }
per_min = after.group_by { _1.strftime('%H:%M') }.transform_values(&:size).sort.map { |m, n| "#{m}=#{n}" }
puts "cap rejects: #{before.size} in the 10 min before, #{after.size} since apply#{per_min.empty? ? '' : " (#{per_min.join(' ')})"}"
