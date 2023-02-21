require 'aws-sdk-secretsmanager'
require 'aws-sdk-sqs'
require 'aws-sdk-dynamodb'
require 'json'
require 'faraday'

module Common
  def initialize(event, context)
    @event = event
    @context = context
  end

  attr_reader :event, :context

  def secret
    @secret ||= begin
      s = secretsmanager.get_secret_value(secret_id: ENV.fetch('SECRET_ARN'), version_stage: 'AWSCURRENT')
      JSON.parse(s.secret_string, symbolize_names: true)
    end
  end

  def secretsmanager
    self.class.secretsmanager
  end

  def dynamodb
    self.class.dynamodb
  end

  def sqs
    self.class.sqs
  end

  def sqs_queue_url
    ENV.fetch('SQS_QUEUE_URL')
  end

  def dynamodb_table
    @dynamodb_table ||= ENV.fetch('DYNAMODB_TABLE')
  end

  def doit?
    !dry_run?
  end

  def dry_run?
    return @dry_run if defined? @dry_run
    @dry_run = ENV['DRY_RUN'] == '1'
  end

  module ClassMethods
    def secretsmanager
      @secretsmanager ||= Aws::SecretsManager::Client.new
    end

    def dynamodb
      @dynamodb ||= Aws::DynamoDB::Client.new
    end

    def sqs
      @sqs ||= Aws::SQS::Client.new
    end
  end

  def self.included(k)
    k.extend(ClassMethods)
  end
end
