#!/usr/bin/env ruby
# Writes wlc_batch.sh input for the AP SOPs in docs/sops/ from a saved `show ap summary`.
#
#   ap_batch.rb name  SUMMARY MAP [ASSETS] [--only REGEX]   asset-tag (or default) names -> ap-* names
#   ap_batch.rb reset SUMMARY MAP [ASSETS] [--only REGEX]   ap-* names -> asset tags, e.g. --only '^ap-trb-'
#   ap_batch.rb group SUMMARY GROUP=REGEX... [--apgroups FILE]   first matching REGEX wins, e.g. rk-hi='^ap-tr[a-c]-' rk-med=.
#   ap_batch.rb mode  SUMMARY local|flexconnect REGEX [--flex-group NAME]   flexconnect also adds the AP to the group (default rk-venue)
#
# MAP and ASSETS are pasted spreadsheet rows (tab, comma or space separated, any column order, header rows ignored).
# MAP rows hold an ap-* name and an asset tag; ASSETS rows hold an asset tag with an Ethernet MAC and/or serial.
# APs are matched by Ethernet MAC, falling back to the current name. Problems go to stderr; exit 1 if any.
require 'optparse'

TAG = /\A(?:rk|kor)-[a-z]+\d{2}[a-z]\d+\z/
AP_NAME = /\Aap-[a-z0-9][a-z0-9-]*\z/
MAC = /\A\h{2}([:.-]?)\h{2}(?:\1\h{2}){4}\z|\A\h{4}\.\h{4}\.\h{4}\z/
SERIAL = /\A[A-Z]{3}[0-9A-Z]{8}\z/
NAME_MAX = 32

Ap = Struct.new(:name, :mac, :model, keyword_init: true)
Entry = Struct.new(:ap_name, :tag, :mac, :serial, keyword_init: true)

def norm_mac(s) = s.downcase.delete(':.-')

def cells(line) = line.split(/[\s,]+/).reject(&:empty?)

def parse_summary(path)
  File.readlines(path, chomp: true).filter_map do |l|
    f = l.split
    next unless f.size >= 4 && f[3].match?(MAC)
    Ap.new(name: f[0], model: f[2], mac: norm_mac(f[3]))
  end.tap { |aps| abort "no AP rows in #{path}; save `show ap summary` output there" if aps.empty? }
end

# `show wlan apgroups`: each "Site Name" block ends with a table of its APs.
def parse_apgroups(path)
  group = nil
  File.readlines(path, chomp: true).each_with_object({}) do |l, h|
    if (m = l.match(/\ASite Name\.+ (\S+)/))
      group = m[1]
    elsif group && (f = l.split).size >= 4 && f[3].match?(MAC)
      h[f[0]] = group
    end
  end
end

def parse_rows(path)
  File.readlines(path, chomp: true).filter_map do |l|
    c = cells(l)
    e = Entry.new(
      ap_name: c.find { _1.match?(AP_NAME) },
      tag: c.find { _1.match?(TAG) },
      mac: c.find { _1.match?(MAC) }&.then { norm_mac(_1) },
      serial: c.find { _1.match?(SERIAL) },
    )
    e if e.ap_name || e.tag
  end
end

def load_entries(map_path, assets_path, problems)
  entries = parse_rows(map_path).select { _1.ap_name && _1.tag }
  abort "no rows with both an ap-* name and an asset tag in #{map_path}" if entries.empty?
  if assets_path
    assets = parse_rows(assets_path).select(&:tag).to_h { [_1.tag, _1] }
    entries.each do |e|
      a = assets[e.tag] or next
      e.mac ||= a.mac
      e.serial ||= a.serial
    end
  end
  %i[ap_name tag mac].each do |k|
    entries.group_by(&k).each { |v, es| abort "#{k} #{v} appears in #{es.size} rows: #{es.map(&:tag).join(' ')}" if v && es.size > 1 }
  end
  entries.each { problems << "#{_1.ap_name}: name longer than #{NAME_MAX} characters" if _1.ap_name.size > NAME_MAX }
  entries
end

def find_ap(aps, e, *names)
  (e.mac && aps.find { _1.mac == e.mac }) || aps.find { names.include?(_1.name) }
end

def rename(aps, entries, only, to:, problems:, matched:)
  entries.filter_map do |e|
    next if only && !e.ap_name.match?(only)
    target = to == :ap_name ? e.ap_name : e.tag
    ap = find_ap(aps, e, e.tag, e.ap_name)
    unless ap
      hint = e.mac ? "MAC #{e.mac}" : "no MAC; look up serial #{e.serial || '?'} with `show ap inventory all`"
      problems << "#{e.ap_name} / #{e.tag}: not on the WLC (#{hint})"
      next
    end
    matched << ap
    next "# #{target} already named" if ap.name == target
    if (clash = aps.find { _1.name == target && _1.mac != ap.mac })
      problems << "#{target}: already used by #{clash.mac}, rename that AP first"
      next
    end
    "config ap name #{target} #{ap.name}"
  end
end

problems = []
lines = []
op = ARGV.shift
case op
when 'name', 'reset'
  only = nil
  OptionParser.new { |o| o.on('--only REGEX') { only = Regexp.new(_1) } }.parse!(ARGV)
  summary, map, assets = ARGV
  abort "usage: #{$0} #{op} SUMMARY MAP [ASSETS] [--only REGEX]" unless summary && map
  aps = parse_summary(summary)
  entries = load_entries(map, assets, problems)
  lines << "# #{op == 'name' ? 'AP names from the deployment map' : 'reset to asset tags'} (#{entries.size} rows in the map)"
matched = []
lines.concat(rename(aps, entries, only, to: op == 'name' ? :ap_name : :tag, problems:, matched:))
if op == 'name'
  (aps - matched).each { problems << "#{_1.name} (#{_1.mac}, #{_1.model}): on the WLC but not in the map" }
end
when 'group'
  apgroups = nil
  OptionParser.new { |o| o.on('--apgroups FILE') { apgroups = parse_apgroups(_1) } }.parse!(ARGV)
  summary, *rules = ARGV
  abort "usage: #{$0} group SUMMARY GROUP=REGEX... [--apgroups FILE]" if !summary || rules.empty?
  rules = rules.map { |r| g, re = r.split('=', 2); [g, Regexp.new(re)] }
  lines << '# AP group assignment; each change restarts the AP'
  parse_summary(summary).sort_by(&:name).each do |ap|
    g, = rules.find { |_, re| ap.name.match?(re) }
    next problems << "#{ap.name}: no rule matches" unless g
    next lines << "# #{ap.name} already in #{g}" if apgroups&.[](ap.name) == g
    lines << "! config ap group-name #{g} #{ap.name}"
  end
when 'mode'
  flex_group = 'rk-venue'
  OptionParser.new { |o| o.on('--flex-group NAME') { flex_group = _1 } }.parse!(ARGV)
  summary, mode, re = ARGV
  abort "usage: #{$0} mode SUMMARY local|flexconnect REGEX [--flex-group NAME]" unless summary && %w[local flexconnect].include?(mode) && re
  re = Regexp.new(re)
  aps = parse_summary(summary).select { _1.name.match?(re) }.sort_by(&:name)
  abort "no AP matches #{re.source}" if aps.empty?
  lines << "# #{aps.size} APs to #{mode} mode; each AP reboots (3-5 min)"
aps.each do |ap|
  lines << "! config ap mode #{mode} #{ap.name}"
  # Without this the AP lands in default-flex-group; the add is refused until the AP is in FlexConnect mode.
  lines << "config flexconnect group #{flex_group} ap add #{ap.mac.scan(/../).join(':')}" if mode == 'flexconnect'
end
else
  abort File.read(__FILE__).lines[1..6].map { _1.sub(/\A# ?/, '') }.join
end

puts lines
problems.each { warn "ap_batch: #{_1}" }
exit(problems.empty? ? 0 : 1)
