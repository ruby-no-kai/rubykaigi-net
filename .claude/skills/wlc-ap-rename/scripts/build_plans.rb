#!/usr/bin/env ruby
# Build per-location rename commands from the asset sheet and a live `show ap summary`.
#
# Usage:
#   build_plans.rb SHEET.tsv SUMMARY.txt OUTDIR
#
# SHEET.tsv is the asset sheet pasted as TSV, with a header row naming the columns
# (--name-col, --mac-col, --asset-col; defaults match the 2026 sheet).
# SUMMARY.txt is `show ap summary` output. Writes OUTDIR/<location>.txt, one
# `config ap name <asset> <current name>` per AP, keyed by the name the AP has now,
# and prints every disagreement between the sheet and the WLC.
require 'fileutils'
require 'optparse'

cols = {name: 'true-name', mac: 'mac-addr', asset: 'asset-tag'}
OptionParser.new do |o|
  o.on('--name-col COL') { cols[:name] = it }
  o.on('--mac-col COL') { cols[:mac] = it }
  o.on('--asset-col COL') { cols[:asset] = it }
end.parse!
sheet_path, summary_path, outdir = ARGV
abort 'usage: build_plans.rb SHEET.tsv SUMMARY.txt OUTDIR' unless outdir

def mac(s) = s.to_s.downcase.delete('^0-9a-f')

header, *rows = File.readlines(sheet_path, chomp: true).map { it.split("\t", -1) }
idx = cols.transform_values { header.index(it) or abort "sheet has no column #{it.inspect}: #{header.inspect}" }
sheet = rows.filter_map do |r|
  name, m, asset = r.values_at(idx[:name], idx[:mac], idx[:asset]).map { it.to_s.strip }
  {name:, mac: mac(m), asset:} unless name.empty? && asset.empty?
end

# AP name in the first column, Ethernet MAC somewhere on the same line.
live = File.readlines(summary_path).filter_map do |line|
  m = line.match(/^(\S+)\s.*?\b((?:\h\h:){5}\h\h)\b/) or next
  {name: m[1], mac: mac(m[2])}
end
live_by_mac = live.to_h { [it[:mac], it] }
sheet_macs = sheet.map { it[:mac] }

problems = []
plans = Hash.new { |h, k| h[k] = [] }
sheet.each do |s|
  if s[:asset].empty? || s[:mac].empty?
    problems << "sheet row incomplete: #{s.inspect}"
  elsif !(l = live_by_mac[s[:mac]])
    problems << "not on WLC: #{s[:name]} #{s[:mac]} #{s[:asset]}"
  elsif l[:name] == s[:asset]
    problems << "already renamed: #{l[:name]}"
  else
    problems << "name differs from sheet: WLC #{l[:name]} / sheet #{s[:name]} (#{s[:mac]})" if l[:name] != s[:name]
    loc = l[:name][/\Aap-([^-]+)-/, 1] || 'other'
    plans[loc] << "config ap name #{s[:asset]} #{l[:name]}"
  end
end
live.reject { sheet_macs.include?(it[:mac]) }.each { problems << "on WLC but not in sheet: #{it[:name]} #{it[:mac]}" }
sheet_macs.tally.select { |_, n| n > 1 }.each_key { problems << "duplicate MAC in sheet: #{it}" }
sheet.map { it[:asset] }.reject(&:empty?).tally.select { |_, n| n > 1 }.each_key { problems << "duplicate asset tag in sheet: #{it}" }

FileUtils.mkdir_p(outdir)
plans.sort.each do |loc, lines|
  File.write(File.join(outdir, "#{loc}.txt"), lines.sort.join("\n") + "\n")
  puts "#{loc}\t#{lines.size}"
end
puts "total\t#{plans.values.sum(&:size)} (WLC has #{live.size})"
warn problems.map { "! #{it}" }.join("\n") unless problems.empty?
