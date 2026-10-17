#!/usr/bin/env ruby
# Samples clients on APs matching a regex: AP, IPv4, global IPv6 count, Connected For, Association Id. Checks RA/IPv6 health per area.
# Usage: client_sample.rb AP_REGEX [N=14]   e.g. client_sample.rb '^ap-(fo0|tra|off)-'   (needs an open wlc-01.venue ssh-cli session)
require 'open3'

REPO = `git rev-parse --show-toplevel`.strip
re = Regexp.new(ARGV.fetch(0))
n = Integer(ARGV.fetch(1, '14'))

def wlc(cmd) = Open3.capture2('ruby', 'misc/ssh_cli.rb', '-s', 'wlc-01.venue', 'run', cmd, chdir: REPO).first

rows = wlc('show client summary').lines.filter_map do |l|
  f = l.split
  f[0] if f[0] =~ /\A\h{2}(:\h{2}){5}\z/ && re.match?(f[1].to_s)
end
puts "#{rows.size} clients on APs matching #{re.source}; sampling #{[n, rows.size].min} at #{Time.now.strftime('%H:%M:%S')}"
stats = rows.sample(n).map do |mac|
  d = wlc("show client detail #{mac}")
  v6 = d.scan(/IPv6 Address\.+\s*(\S+)/).flatten.reject { _1.start_with?('fe80') }.uniq.size
  row = { ap: d[/AP Name\.+\s*(\S+)/, 1], v4: d[/\nIP Address\.+\s*(\S+)/, 1], v6:, secs: d[/Connected For\s*\.+\s*(\d+)/, 1].to_i, aid: d[/Association Id\.+\s*(\d+)/, 1] }
  puts format('  %s %-10s v4=%-15s global6=%d conn=%5ds aid=%s', mac, row[:ap], row[:v4], row[:v6], row[:secs], row[:aid])
  row
end
puts "with global IPv6: #{stats.count { _1[:v6].positive? }}/#{stats.size}; under 190 s: #{stats.count { _1[:secs] < 190 }}; aid 0: #{stats.count { _1[:aid] == '0' }}"
