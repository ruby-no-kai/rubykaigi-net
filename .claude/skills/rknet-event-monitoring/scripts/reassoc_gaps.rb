#!/usr/bin/env ruby
# Histogram of per-MAC gaps between WLC re-association events in a syslog.sh output file.
# A peak at 170-200 s is the FlexConnect DHCP-required removal (rknet-wifi-remediation). Steadier than Connected For samples while crowds move.
# Usage: reassoc_gaps.rb FILE [PATTERN=MOBILESTATION_NOT_FOUND]
require 'time'

file = ARGV.fetch(0)
pattern = ARGV.fetch(1, 'MOBILESTATION_NOT_FOUND')
MAC = /\b(\h{2}(?::\h{2}){5})\b/

times = Hash.new { |h, k| h[k] = [] }
File.foreach(file) do |line|
  next unless line.include?(pattern)

  mac = line[MAC, 1] or next
  times[mac] << Time.parse(line[0, 8])
end

gaps = times.values.flat_map { |ts| ts.sort.uniq.each_cons(2).map { |a, b| (b - a).round } }.select(&:positive?)
abort "no #{pattern} gaps in #{file}" if gaps.empty?

cycle = gaps.count { (170..200).cover?(_1) }
puts "#{pattern}: #{times.size} MACs, #{gaps.size} gaps, 170-200 s: #{cycle} (#{(100.0 * cycle / gaps.size).round(1)}%)"
[[0, 60], [60, 120], [120, 170], [170, 200], [200, 300], [300, 600], [600, 1800], [1800, nil]].each do |lo, hi|
  n = gaps.count { _1 >= lo && (hi.nil? || _1 < hi) }
  puts format('  %5s-%-5s %5d %s', lo, hi || '', n, '#' * (60.0 * n / gaps.size).ceil)
end
