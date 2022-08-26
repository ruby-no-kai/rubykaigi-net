# https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotate-secrets_how.html
require 'openssl'
require 'json'
require 'aws-sdk-secretsmanager'

RotationRequest = Struct.new(:step, :id, :token, :secret, keyword_init: true)

def handler(event:, context:)
  @secretsmanager ||= Aws::SecretsManager::Client.new()
  
  secret = prerequisite_check!(event)

  req = RotationRequest.new(
    step: event.fetch('Step'),
    token: event.fetch('ClientRequestToken'),
    id: event.fetch('SecretId'),
    secret: secret,
  )

  case event.fetch('Step')
  when 'createSecret'
    create_secret(req)
  when 'setSecret'
    set_secret(req)
  when 'testSecret'
    test_secret(req)
  when 'finishSecret'
    finish_secret(req)
  end
end

def prerequisite_check!(event)
  secret = @secretsmanager.describe_secret(secret_id: event.fetch('SecretId'))
  raise "secret #{secret.arn.inspect} have not enabled rotation" unless secret.rotation_enabled
  stages = secret.version_ids_to_stages[event.fetch('ClientRequestToken')]
  raise "Secret version #{event.fetch('ClientRequestToken').inspect} has no stage for secret #{secret.arn.inspect}" unless stages
  raise "Secret version #{event.fetch('ClientRequestToken').inspect} is on AWSCURRENT for secret #{secret.arn.inspect}" if stages.include?('AWSCURRENT') && !stages.include?('AWSPENDING')
  raise "Secret version #{event.fetch('ClientRequestToken').inspect} is not on AWSPENDING for secret #{secret.arn.inspect}" unless stages.include?('AWSPENDING')
  secret
end

def create_secret(req)
  current = begin
    @secretsmanager.get_secret_value(secret_id: req.id, version_stage: 'AWSCURRENT')
  rescue Aws::SecretsManager::Errors::ResourceNotFoundException
    nil
  end
  puts "createSecret: current version is: #{current.version_id} @ #{current.arn}" if current

  begin
    @secretsmanager.get_secret_value(secret_id: req.id, version_id: req.token, version_stage: 'AWSPENDING')
  rescue Aws::SecretsManager::Errors::ResourceNotFoundException
    puts "createSecret: generating for #{req.token} @ #{req.id}"

    @secretsmanager.put_secret_value(
      secret_id: req.id,
      client_request_token: req.token,
      secret_string: generate_secret(req, current),
    )
  else
    puts "createSecret: do nothing for #{req.token} @ #{req.id}"
  end
end

def generate_secret(req, _current)
  rsa = OpenSSL::PKey::RSA.generate(2048)
  JSON.generate({rsa: {pem: rsa.to_pem}})
end

def set_secret(req)
  _check = @secretsmanager.get_secret_value(secret_id: req.id, version_id: req.token, version_stage: 'AWSPENDING')
  puts "setSecret: do nothing for #{req.token} @ #{req.id}"
end

def test_secret(req)
  _check = @secretsmanager.get_secret_value(secret_id: req.id, version_id: req.token, version_stage: 'AWSPENDING')
  puts "testSecret: do nothing for #{req.token} @ #{req.id}"
end

def finish_secret(req)
  current_version = req.secret.version_ids_to_stages.find { |k,v| v.include?('AWSCURRENT') }.first
  if current_version == req.token
    puts "finishSecret: #{current_version} on #{req.id} is on AWSCURRENT, do nothing"
    return
  end

  puts "finishSecret: update_secret_version_stage AWSCURRENT to #{req.token} from #{current_version} for #{req.id}"
  @secretsmanager.update_secret_version_stage(
    secret_id: req.id,
    version_stage: 'AWSCURRENT',
    move_to_version_id: req.token,
    remove_from_version_id: current_version,
  )
end
