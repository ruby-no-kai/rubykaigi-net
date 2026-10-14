#!/usr/bin/env ruby
# Generates the SSH key of the glazed user, stores its private key in SSM /glazed/prd/ssh-key, and prints the public key.
#
#   mairu exec auto ./generate-ssh-key.rb
#
# The previous key stops working once devices have only the new public key.
require 'tmpdir'

PARAMETER = '/glazed/prd/ssh-key'

File.umask(0o077)
# Kept in memory only, and removed with the directory.
Dir.mktmpdir('glazed-ssh-key', '/dev/shm') do |dir|
  key = File.join(dir, 'id_ed25519')
  system('ssh-keygen', '-q', '-t', 'ed25519', '-N', '', '-C', 'glazed', '-f', key, exception: true)
  # file:// keeps the private key out of the process arguments.
  system(
    'aws', 'ssm', 'put-parameter',
    '--region', 'ap-northeast-1',
    '--name', PARAMETER,
    '--type', 'SecureString',
    '--overwrite',
    '--value', "file://#{key}",
    out: File::NULL,
    exception: true,
  )
  File.delete(key)

  public_key = File.read("#{key}.pub").chomp
  warn "Stored the private key in #{PARAMETER}"
  puts public_key
  puts
  puts 'Junos:'
  puts "  set system login user glazed authentication ssh-ed25519 \"#{public_key}\""
end
