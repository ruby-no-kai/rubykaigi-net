# Applies a JSON patch from stdin to DIR/data.json, following the board rules, then rebuilds the page.
# Usage: ruby update.rb DIR <<'JSON'
#   {"at": "11:08",
#    "status": {"verdict": "...", "level": "warn", "clients": 820},
#    "issues": [{"num": 15, "status": "open", "latest": "...", "next": "...", "facts": ["11:07 ..."], "note": "history line"},
#               {"num": 27, "title": "...", "severity": "low", "status": "open", "detection": "...", "latest": "...", "next": "..."}]}
#   JSON
# Existing issues: scalar fields are replaced, `facts` are appended, `note` becomes a history entry at `at`.
# `detection` and `first_seen` are never changed. A new number must follow the highest one, or `last_num` in data.json
# (set it on a new day's board so numbering continues across the event).
require 'json'

dir = File.expand_path(ARGV.fetch(0))
path = File.join(dir, 'data.json')
data = JSON.parse(File.read(path))
patch = JSON.parse($stdin.read)
at = patch.fetch('at')

data['status'] = data.fetch('status', {}).merge(patch.fetch('status', {})).merge('checked_at' => at) if patch.key?('status')

patch.fetch('issues', []).each do |change|
  num = change.fetch('num')
  issue = data['issues'].find { _1['num'] == num }
  if issue.nil?
    expected = [data['issues'].map { _1['num'] }.max.to_i, data['last_num'].to_i].max + 1
    abort "new issue ##{num}: next number is ##{expected}" unless num == expected
    %w[title severity status detection].each { |k| abort "new issue ##{num}: missing #{k}" unless change.key?(k) }
    issue = { 'num' => num, 'first_seen' => at, 'facts' => [], 'history' => [], 'action' => '', 'evidence' => '' }
    data['issues'] << issue
    data['last_num'] = num
    change = change.merge('note' => change.fetch('note', 'First seen.'))
  else
    abort "##{num}: detection is written once" if change.key?('detection')
  end
  change.each do |k, v|
    case k
    when 'num', 'first_seen' then nil
    when 'facts' then issue['facts'].concat(Array(v))
    when 'note' then issue['history'] << { 'at' => at, 'note' => v }
    else issue[k] = v
    end
  end
  issue['updated'] = at
end

File.write(path, JSON.pretty_generate(data))
system('ruby', File.join(__dir__, 'build.rb'), dir, exception: true)
