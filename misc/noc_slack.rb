#!/usr/bin/env ruby
# Posts Slack mrkdwn from stdin to the NOC channel webhook.
# Usage: ruby misc/noc_slack.rb [--dry-run] < message.txt
# The webhook URL comes from NOC_SLACK_WEBHOOK or tmp/noc_slack_webhook, which is gitignored so the URL stays out of the repo.
require 'json'
require 'net/http'
require 'uri'

WEBHOOK_FILE = File.expand_path('../tmp/noc_slack_webhook', __dir__)

dry_run = ARGV.delete('--dry-run')
text = $stdin.read.strip
abort 'empty message' if text.empty?

payload = JSON.generate(text: text)
if dry_run
  puts payload
  exit
end

url = URI(ENV.fetch('NOC_SLACK_WEBHOOK') { File.read(WEBHOOK_FILE).strip })
res = Net::HTTP.post(url, payload, 'Content-Type' => 'application/json')
abort "slack: #{res.code} #{res.body}" unless res.is_a?(Net::HTTPSuccess)
puts 'posted'
