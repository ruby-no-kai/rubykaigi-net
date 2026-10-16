#!/usr/bin/env ruby
# Prints a GitHub App installation token for ruby-no-kai/rubykaigi-net, from tf/sts-cat with the AWS web identity token of the caller.
# glazed.jsonnet embeds it as the token command of the github storage. .github/sts-cat/glazed.sts.toml trusts the role of the glazed-github function.
require 'bundler/setup'
require 'aws-sdk-sts'
require 'httpx'
require 'json'

AUDIENCE = 'https://sts-cat.rubykaigi.net'
ENDPOINT = 'https://yrlrly5nve2l23wqbwumadvi4i0wchbp.lambda-url.ap-northeast-1.on.aws/token'

jwt = Aws::STS::Client.new.get_web_identity_token(audience: [AUDIENCE], signing_algorithm: 'RS256').web_identity_token
response = HTTPX.post(
  ENDPOINT,
  headers: { 'authorization' => "Bearer #{jwt}" },
  json: { scope: 'ruby-no-kai/rubykaigi-net', identity: 'glazed' },
)
response.raise_for_status
puts JSON.parse(response.body.to_s).fetch('token')
