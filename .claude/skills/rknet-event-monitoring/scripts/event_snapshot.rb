#!/usr/bin/env ruby
# Snapshot for before/after comparisons: clients per SSID/area, retry and fail ratios, WLC CPU, cs-01 irb.400 RS/RA rates,
# 180 s re-association share. Usage: ruby event_snapshot.rb [CLIENT_SAMPLE=40]
# Needs open sessions: wlc-01.venue (aireos) and cs-01.venue (junos), and kubectl access for Prometheus.
require 'json'
require 'open3'

REPO = `git rev-parse --show-toplevel`.strip
PROM = File.join(REPO, '.claude/skills/rknet-observability/scripts/prom.rb')
SAMPLE = Integer(ARGV.fetch(0, '40'))

def sh(*cmd) = Open3.capture2(*cmd, chdir: REPO).first
def wlc(c) = sh('ruby', 'misc/ssh_cli.rb', '-s', 'wlc-01.venue', 'run', c)
def cs(c) = sh('ruby', 'misc/ssh_cli.rb', '-s', 'cs-01.venue', 'run', c)

def prom(q, keys)
  j = JSON.parse(sh('ruby', PROM, '--raw', 'query', q))
  (j.dig('data', 'result') || []).to_h { |r| [keys.map { r['metric'][_1] }, r['value'][1].to_f] }
rescue JSON::ParserError
  {}
end

def ra
  o = cs('show ipv6 router-advertisement interface irb.400 | no-more')
  [o[/Advertisements sent: (\d+)/, 1].to_i, o[/Solicits received: (\d+)/, 1].to_i, Time.now]
end

puts "== snapshot #{Time.now.strftime('%Y-%m-%d %H:%M:%S')}"
ra0 = ra

ssid = prom('sum by (bsnDot11EssSsid) (bsnDot11EssNumberOfMobileStations)', %w[bsnDot11EssSsid])
puts 'SSID clients: ' + ssid.sort_by { -_2 }.map { |(s), n| "#{s}=#{n.to_i}" }.join(', ')
users = prom('bsnApIfNoOfUsers', %w[bsnAPName bsnAPIfSlotId])
area = Hash.new(0)
users.each { |(ap, _), n| area[ap[/^ap-(.+?)-/, 1]] += n.to_i }
puts 'clients per area: ' + area.sort_by { |a, _| a.to_s }.map { |a, n| "#{a}=#{n}" }.join(' ') + "  total=#{area.values.sum}"

tx = prom('rate(bsnAPIfDot11TransmittedFrameCount{bsnAPIfSlotId="1"}[5m])', %w[bsnAPName])
fl = prom('rate(bsnAPIfDot11FailedCount{bsnAPIfSlotId="1"}[5m])', %w[bsnAPName])
rt = prom('rate(bsnAPIfDot11RetryCount{bsnAPIfSlotId="1"}[5m])', %w[bsnAPName])
rows = tx.select { _2 > 50 }.map { |k, t| [k[0], t, 100 * fl.fetch(k, 0) / t, 100 * rt.fetch(k, 0) / t] }
tot = rows.sum { _2 }
puts format('5 GHz overall (5 min): tx %.0f fps, failed %.1f%%, retry %.1f%%', tot, 100 * rows.sum { _2 * _3 / 100 } / tot, 100 * rows.sum { _2 * _4 / 100 } / tot)
puts 'worst failed ratio radios: ' + rows.sort_by { -_3 }.first(6).map { |ap, _, f, r| format('%s %.0f%%/%.0f%%', ap, f, r) }.join(', ') + '  (failed/retry)'

puts 'WLC CPU: ' + wlc('show cpu').lines.grep(/CPU|average|utili/i).first(3).map(&:strip).join(' | ')

macs = wlc('show client summary').lines.filter_map { |l| l.split[0] if l =~ /^[0-9a-f]{2}(:[0-9a-f]{2}){5} +ap-/ && l.include?('Associated') }
ghosts = 0
rows = macs.sample(SAMPLE).filter_map do |m|
  d = wlc("show client detail #{m}")
  s = d[/Connected For\s*\.+\s*(\d+)/, 1] or next
  ghosts += 1 and next if d[/Association Id\.+\s*(\d+)/, 1] == '0'

  ip = d[/\nIP Address\.+\s*(\S+)/, 1].to_s
  kind = ip == '192.0.0.2' ? :clat : (ip.match?(/^\d+\.\d+\.\d+\.\d+$/) && ip != '0.0.0.0' ? :v4 : :none)
  { secs: s.to_i, kind:, ssid: d[/Network Name \(SSID\)\.+\s*(.+)$/, 1].to_s.strip }
end
puts "ghost entries skipped (Association Id 0, not on the AP): #{ghosts}"
puts "sample #{rows.size} of #{macs.size} clients (IPv4 kind: none = no address, clat = 192.0.0.2 learned by the AP, v4 = real DHCP address):"
%i[none clat v4].each do |k|
  g = rows.select { _1[:kind] == k }
  next puts("  #{k}: n=0") if g.empty?

  u = g.count { _1[:secs] < 190 }
  puts format('  %-4s n=%2d  under 190 s %2d (%.0f%%)  median %ds', k, g.size, u, 100.0 * u / g.size, g.map { _1[:secs] }.sort[g.size / 2])
end
puts '  by SSID: ' + rows.group_by { _1[:ssid] }.map { |s, g| "#{s}=#{g.size}" }.join(', ')

ra1 = ra
m = (ra1[2] - ra0[2]) / 60
puts format('cs-01 irb.400 over %.1f min: RS received %.0f/min, RA sent %.0f/min', m, (ra1[1] - ra0[1]) / m, (ra1[0] - ra0[0]) / m)
