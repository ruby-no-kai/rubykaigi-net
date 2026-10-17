#!/usr/bin/env ruby
# Sample associated clients: Policy Manager State against Connected For, to see how long clients wait before RUN.
require 'open3'

REPO = `git rev-parse --show-toplevel`.strip
SAMPLE = Integer(ARGV.fetch(0, '80'))

def wlc(cmd)
  out, = Open3.capture2('ruby', 'misc/ssh_cli.rb', '-s', 'wlc-01.venue', 'run', cmd, chdir: REPO)
  out
end

macs = wlc('show client summary').lines.filter_map { |l| l.split[0] if l =~ /^[0-9a-f]{2}(:[0-9a-f]{2}){5} +ap-/ }
rows = macs.sample(SAMPLE).filter_map do |mac|
  d = wlc("show client detail #{mac}")
  state = d[/Policy Manager State\.+\s*(\S+)/, 1]
  secs = d[/Connected For\s*\.+\s*(\d+) secs/, 1]
  ipv6 = d.scan(/IPv6 Address\.+\s*(\S+)/).flatten.reject { _1.start_with?('fe80') }
  next unless state && secs

  { state:, secs: secs.to_i, global_v6: ipv6.size }
end

puts "sampled #{rows.size} of #{macs.size} clients at #{Time.now.strftime('%H:%M:%S')}"
rows.group_by { _1[:state] }.sort_by { -_2.size }.each do |state, rs|
  s = rs.map { _1[:secs] }.sort
  puts format('%-12s n=%2d (%.0f%%)  Connected For median %4ds  min %4ds  max %4ds  with global IPv6 address: %d',
              state, rs.size, 100.0 * rs.size / rows.size, s[s.size / 2], s.first, s.last, rs.count { _1[:global_v6].positive? })
end
not_run = rows.reject { _1[:state] == 'RUN' }
puts "not RUN and connected over 20 s: #{not_run.count { _1[:secs] > 20 }} of #{rows.size}; over 40 s: #{not_run.count { _1[:secs] > 40 }}"
run_under_20 = rows.select { _1[:state] == 'RUN' && _1[:secs] <= 20 }
puts "RUN within 20 s of connecting: #{run_under_20.size}"
