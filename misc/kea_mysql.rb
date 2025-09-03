#!/usr/bin/env ruby
require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'aws-sdk-rds'
  gem 'aws-sdk-s3'
  gem 'rexml'
end
require 'thread'
require 'socket'
require 'open-uri'
require 'json'

EP = begin
  Aws::S3::Client.new(region: 'ap-northeast-1').get_object(bucket: 'rk-infra', key: 'terraform/nw-dhcp.tfstate')
    .then { JSON.parse(_1.body.read) }
    .then { _1.fetch('outputs').fetch('rds_endpoint').fetch('value') }
 end
BASTION =  'bastion.rubykaigi.net'
USER = 'rk'
CA_BUNDLE = 'https://truststore.pki.rds.amazonaws.com/ap-northeast-1/ap-northeast-1-bundle.pem'
ca_bundle = Tempfile.open(['rds-ca-bundle', '.pem']).tap do |io|
  io.write URI.open(CA_BUNDLE,'r',&:read)
  io.flush
end


#portsock = TCPServer.new('127.0.0.1', 0)
#port = portsock.addr[1]
port = 13316

origppid = Process.pid
child = fork() do
  #portsock.close
  pid = spawn('ssh', '-L', "127.0.0.1:#{port}:#{EP}:3306", '-N', BASTION)
  warn "ssh: #{pid}"
  q2 = Queue.new
  Thread.new do
    loop do
      break if Process.ppid() != origppid
      sleep 5
    end
    q2.push(nil)
  end
  Thread.new do
    Process.waitpid2(pid) rescue nil
    q2.push(nil)
  end
  q2.pop
  exit 0
ensure
  if pid
    Process.kill(:TERM, pid) rescue nil
    Process.waitpid2(pid) rescue nil
  end
  exit 0
end

loop do
  sock = TCPSocket.new('127.0.0.1', port)
  break sock.close
rescue
  sleep 0.1
end
auth = Aws::RDS::AuthTokenGenerator.new(credentials: Aws::CredentialProviderChain.new.resolve)
token = auth.generate_auth_token(region: 'ap-northeast-1', endpoint: "#{EP}:3306", expires_in: 900, user_name: USER)

ENV['MYSQL_PWD'] = token
exec 'mysql', '-h', '127.0.0.1', '-P', port.to_s, '-u', USER, '--enable-cleartext-plugin', '--ssl-ca', ca_bundle.path, 'kea'

