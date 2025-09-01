require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'aws-sdk-s3'
  gem 'rexml'
end
require 'open-uri'
require 'json'
require 'logger'

ssh_import_id = JSON.parse(File.read(ENV['SSH_IMPORT_ID_FILE']))

all_keys = []
ssh_import_id.each do |x|
  next unless x.start_with?('gh:')
  login = x.sub(/^gh:/,'')

  url = "https://api.github.com/users/#{login}/keys"
  p url
  keys = JSON.parse(URI.open(url, "r", &:read))

  nonrsa = keys.map { _1.fetch('key') }.any? { _1.start_with?('ssh-ed25519') || _1.start_with?('ecdsa-') }

  keys.each do |key|
    kty = {
      'ssh-rsa' => :rsa,
      'ecdsa-sha2-nistp256' => :ecdsa,
      'ecdsa-sha2-nistp384' => :ecdsa,
      'ecdsa-sha2-nistp521' => :ecdsa,
      'ssh-ed25519' => :ed25519,
    }[key.fetch('key').split(' ', 2)[0]]
    next unless kty
    next if nonrsa && kty == :rsa

    all_keys << "#{key.fetch('key')} #{login}@github/#{key.fetch('id')}"
  end
end

Aws::S3::Client.new(logger: Logger.new($stdout))
  .put_object(
    bucket: ENV.fetch('S3_BUCKET'),
    key: ENV.fetch('S3_KEY'),
    content_type: 'text/plain',
    body: all_keys.join("\n") + "\n",
  )
