require 'open-uri'
require 'yaml'

cloud_config = YAML.safe_load(File.read("tf/bastion/bastion.yml"))

user = cloud_config.fetch('users').find { _1['name'] == 'rk' }

puts "top"
puts "edit system login user rk authentication"
user.fetch('ssh_import_id').each do |x|
  url = "https://github.com/#{x.sub(/^gh:/,'')}.keys"
  keys = URI.open(url, "r", &:read).each_line.map(&:chomp)
  nonrsa = keys.any? { _1.start_with?('ssh-ed25519') || _1.start_with?('ecdsa-') }

  keys.each do |key|
    kty = {
      'ssh-rsa' => :rsa,
      'ecdsa-sha2-nistp256' => :ecdsa,
      'ecdsa-sha2-nistp384' => :ecdsa,
      'ecdsa-sha2-nistp521' => :ecdsa,
      'ssh-ed25519' => :ed25519,
    }[key.split(' ', 2)[0]]
    next unless kty
    next if nonrsa && kty == :rsa
    puts %(set ssh-#{kty} "#{key}")
    puts %(annotate ssh-#{kty} "#{key}" "#{url}")
  end
end
