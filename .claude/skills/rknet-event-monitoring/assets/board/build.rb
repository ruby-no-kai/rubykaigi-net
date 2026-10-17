# Renders template.html with data.json embedded. Usage: ruby build.rb [DIR_WITH_DATA_JSON=.] [OUT_HTML=DIR/issue-board.html]
# The data is embedded rather than read from an Artifact db, so signed-out viewers of a shared link can read it.
require 'json'
require 'cgi'
dir = File.expand_path(ARGV.fetch(0, '.'))
data = JSON.parse(File.read(File.join(dir, 'data.json')))
json = JSON.generate(data).gsub('</', '<\/')
title = CGI.escapeHTML(data['title'] || [data['event'], 'NOC Issues'].compact.join(' · '))
html = File.read(File.join(__dir__, 'template.html')).sub('/*BOARD_DATA*/') { json }.sub('<title>NOC Issues</title>') { "<title>#{title}</title>" }
out = ARGV.fetch(1, File.join(dir, 'issue-board.html'))
File.write(out, html)
puts "built: #{data['issues'].size} issues, checked #{data.dig('status', 'checked_at')} -> #{out}"
