require 'bundler/inline'
gemfile do
  source 'https://rubygems.org'
  gem 'aws-sdk-ssm'
end

require 'open-uri'
require 'yaml'

@ssm = Aws::SSM::Client.new(region: 'ap-northeast-1')
password_arn =  'arn:aws:ssm:ap-northeast-1:005216166247:parameter/noc/rk_password_hash'
password_hash = @ssm.get_parameter(name: password_arn, with_decryption: true).parameter.value
password_project = @ssm.list_tags_for_resource(resource_type: 'Parameter', resource_id: password_arn).tag_list.find { _1.key == 'Project' }&.value || 'unknown'

ssh_import_id = YAML.safe_load(File.read("data/ssh_import_ids.json"))

is_set = !!ARGV.delete('--set')

if is_set
  puts "top"
  puts "edit system login user rk authentication"
else
  puts <<~EOF
    ## Load with `load replace terminal`
    system {
      root-authentication {
        /* rk for #{password_project} - rkroot is rkroot user */
        encrypted-password "#{password_hash}";
      }
      login {
        user rk {
          replace: authentication {
            /* #{password_project} */
            encrypted-password "#{password_hash}";
  EOF
end

ssh_import_id.each do |x|
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
    if is_set
      puts %(set ssh-#{kty} "#{key}")
      puts %(annotate ssh-#{kty} "#{key}" "#{url}")
    else
      puts %(        /* #{url} */)
      puts %(        ssh-#{kty} "#{key}";)
    end
  end
end

unless is_set
  puts <<~EOF
          }
        }
      }
    }
  EOF
end
