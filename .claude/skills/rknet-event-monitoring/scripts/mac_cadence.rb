#!/usr/bin/env ruby
# One client's association cadence: WLC client detail plus the times of its USE_DEFAULT_CIPHER_SUITE syslog events and the gaps between them.
# Usage: mac_cadence.rb MAC [HOURS=2]   (LOG_GROUP env overrides /rk26net/syslog; needs an open wlc-01.venue ssh-cli session)
require 'json'
require 'open3'

mac = ARGV.fetch(0).downcase
hours = Float(ARGV.fetch(1, '2'))
repo = `git rev-parse --show-toplevel`.strip
log_group = ENV.fetch('LOG_GROUP', '/rk26net/syslog')

detail, = Open3.capture2('ruby', 'misc/ssh_cli.rb', '-s', 'wlc-01.venue', 'run', "show client detail #{mac}", chdir: repo)
fields = detail.lines.grep(/^(AP Name|Network Name|Connected For|IP Address|Policy Manager State|Association Id)\b/).map { _1.squeeze(' .').strip }
puts "#{mac}: #{fields.empty? ? 'not on the WLC' : fields.join(' | ')}"

out, status = Open3.capture2(
  'aws', 'logs', 'filter-log-events', '--region', 'ap-northeast-1', '--log-group-name', log_group,
  '--log-stream-name-prefix', 'wlc-01', '--filter-pattern', %("#{mac}" "USE_DEFAULT_CIPHER_SUITE"),
  '--start-time', ((Time.now.to_i - (hours * 3600).to_i) * 1000).to_s, '--query', 'events[].timestamp', '--output', 'json'
)
abort 'aws logs failed' unless status.success?

ts = JSON.parse(out).sort.map { Time.at(_1 / 1000).getlocal('+09:00') }.uniq
puts "  #{ts.size} association events in #{hours} h; last: #{ts.last(8).map { _1.strftime('%H:%M:%S') }.join(' ')}"
puts "  gaps (s): #{ts.each_cons(2).map { |a, b| (b - a).round }.last(12).join(' ')}"
