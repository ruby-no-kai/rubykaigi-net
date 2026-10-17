#!/usr/bin/env ruby
# Logs every client of one AP every few minutes: policy state, IPv4, global IPv6 address count, Connected For, byte deltas.
# Usage: ap_watch.rb AP_NAME [INTERVAL_SEC=240] [STOP_HOUR=22]   (needs an open wlc-01.venue ssh-cli session)
# A Connected For that drops between rounds is a re-association. Run in the background and append to a log in tmp/.
require 'open3'

ap = ARGV.fetch(0)
interval = Integer(ARGV.fetch(1, '240'))
stop_hour = Integer(ARGV.fetch(2, '22'))
repo = `git rev-parse --show-toplevel`.strip

def wlc(repo, cmd) = Open3.capture2('ruby', 'misc/ssh_cli.rb', '-s', 'wlc-01.venue', 'run', cmd, chdir: repo).first

prev = {}
loop do
  now = Time.now
  break if now.hour >= stop_hour

  macs = wlc(repo, 'show client summary').lines.filter_map { |l| l.split[0] if l =~ /^[0-9a-f]{2}(:[0-9a-f]{2}){5} +#{Regexp.escape(ap)} / }
  puts "== #{now.strftime('%H:%M:%S')} #{ap} clients=#{macs.size}"
  macs.each do |m|
    d = wlc(repo, "show client detail #{m}")
    v6 = d.scan(/IPv6 Address\.+\s*(\S+)/).flatten.reject { _1.start_with?('fe80') }.size
    rx = d[/Number of Bytes Received\.+\s*(\d+)/, 1].to_i
    tx = d[/Number of Bytes Sent\.+\s*(\d+)/, 1].to_i
    delta = prev[m] ? "d_rx=#{rx - prev[m][0]} d_tx=#{tx - prev[m][1]}" : 'new'
    puts "#{m} #{d[/Policy Manager State\.+\s*(\S+)/, 1]} v4=#{d[/\nIP Address\.+\s*(\S+)/, 1]} v6g=#{v6} conn=#{d[/Connected For\s*\.+\s*(\d+)/, 1]}s aid=#{d[/Association Id\.+\s*(\d+)/, 1]} rx=#{rx} tx=#{tx} #{delta}"
    prev[m] = [rx, tx]
  end
  $stdout.flush
  sleep interval
end
