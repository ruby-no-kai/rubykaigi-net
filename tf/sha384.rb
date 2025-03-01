# terraform external data source
require 'openssl'
require 'json'

query = JSON.load($stdin)
data = query.fetch('data')

puts JSON.pretty_generate(
  hexdigest: OpenSSL::Digest::SHA384.hexdigest(data),
)
