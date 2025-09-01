require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'trilogy'
  gem 'bigdecimal' # https://github.com/trilogy-libraries/trilogy/commit/6b4e12410d9cdcbe07454b0b8af888972f578b1c
end
require 'tempfile'
require 'open-uri'

begin
  forwarder = spawn(*%w(ssh -N -L), "127.0.0.1:13366:#{ENV.fetch('RDS_HOST')}:#{ENV.fetch('RDS_PORT')}", 'bastion.rubykaigi.net')
  warn  "127.0.0.1:13366:#{ENV.fetch('RDS_HOST')}:#{ENV.fetch('RDS_PORT')}"

  client = nil
  loop do
    client = Trilogy.new(host: "127.0.0.1", port: 13366, username: ENV.fetch('RDS_USER'), password: ENV.fetch('RDS_PASSWORD'), read_timeout: 2, multi_statement: true)
    break
  rescue Trilogy::SyscallError::ECONNREFUSED
    sleep 0.2
    retry
  end

  client.query(%(drop user 'rk')) rescue nil
  client.query(%(create user 'rk' identified with AWSAuthenticationPlugin as 'RDS'))
  client.query(%(grant all on `%`.* to 'rk'@'%'))
  client.query(%(alter user 'rk'@'%' require SSL))

  client.query(%(drop user 'kea-admin')) rescue nil
  client.query(%(create user 'kea-admin' identified with AWSAuthenticationPlugin as 'RDS'))
  client.query(%(grant all on `kea`.* to 'kea-admin'@'%'))
  client.query(%(alter user 'kea-admin'@'%' require SSL))

  client.query(%(drop user 'kea')) rescue nil
  client.query(%(create user 'kea'@'%' identified by '#{client.escape(ENV.fetch('TARGET_PASSWORD'))}'))
  client.query(%(grant all on kea.* to 'kea'@'%'))
  client.query(%(flush privileges))
  client.close

  # Kea-3.1.1
  sql = URI.open('https://raw.githubusercontent.com/isc-projects/kea/f89b3898b3f6eab670e08067582d3256a99cad79/src/share/database/scripts/mysql/dhcpdb_create.mysql', 'r', &:read)
  tempfile = Tempfile.new
  tempfile.write(sql)
  tempfile.flush
  tempfile.rewind
  system({'MYSQL_PWD' => ENV.fetch('RDS_PASSWORD')}, 'mysql', '-h', '127.0.0.1', '-u', ENV.fetch('RDS_USER'), '-P13366', 'kea', in: tempfile.to_io, exception: true)
ensure
  Process.kill('TERM', forwarder) if forwarder
end
