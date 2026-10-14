#!/usr/bin/env ruby
# Generate glazed configuration JSON from glazed/*.jsonnet into gen/glazed/.
#
# tf/glazed uploads gen/glazed/glazed.json for the Lambda function; apply it after rendering.
#
# To back up device configurations by hand, inside the NOC network and with AWS credentials for SSM and S3:
#   (cd glazed && bundle install)
#   ./gen-glazed.rb
#   BUNDLE_GEMFILE=glazed/Gemfile bundle exec glazed run -c gen/glazed/glazed.json [--only br-01.hnd,tun-01.venue]
# Configurations land in s3://rk-infra/glazed/{raw,redacted}/.
require 'fileutils'
require 'json'

jsonnet = system('jrsonnet', '--help', out: File::NULL, err: [:child, :out]) ? 'jrsonnet' : 'jsonnet'

Dir.chdir(__dir__)
FileUtils.mkdir_p('gen/glazed')

Dir['glazed/*.jsonnet'].each do |src|
  dst = File.join('gen/glazed', "#{File.basename(src, '.jsonnet')}.json")
  json = IO.popen([jsonnet, src], &:read)
  raise "#{jsonnet} failed for #{src}" unless $?.success?

  File.write(dst, "#{JSON.pretty_generate(JSON.parse(json))}\n")
  puts dst
end
