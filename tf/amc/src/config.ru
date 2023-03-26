# config.ru
require 'omniauth'
require 'omniauth-himari'
require 'rack'
require 'rack/session/cookie'
require 'secure_headers'
require 'apigatewayv2_rack'
require_relative './app'

require 'aws-sdk-secretsmanager'
secret = JSON.parse(Aws::SecretsManager::Client.new().get_secret_value(secret_id: ENV.fetch('AMC_SECRET_PARAMS_ARN'), version_stage: 'AWSCURRENT').secret_string)

use(Class.new do
  def initialize(app)
    @app = app
  end
  def call(env)
    env['rack.errors'] = $stderr
    @app.call(env)
  end
end)

use Rack::Logger
use Apigatewayv2Rack::Middlewares::CloudfrontXff
use Rack::CommonLogger
use(Class.new do
  def initialize(app)
    @app = app
  end
  def call(env)
    @app.call(env)
  end
end)

SecureHeaders::Configuration.default do |config|
  config.cookies = {secure: true, httponly: true, samesite: {lax: true}}
  config.hsts = "max-age=#{(90*86400)}"
end
use SecureHeaders::Middleware

use(Rack::Session::Cookie,
  key: '__Host-amc-sess',
  path: '/',
  secure: true,
  expire_after: 3600 * 1,
  secret: secret.fetch('SECRET_KEY_BASE'),
)

use OmniAuth::Builder do
  configure do |conf|
    conf.allowed_request_methods = %i[get]
    conf.silence_get_warning = true
  end

  provider(
    :himari,
    site: 'https://idp.rubykaigi.net',
    client_id: '87a353c4-f268-4399-ade3-de8f06cbc172',
    client_secret: secret.fetch('AMC_CLIENT_SECRET'),
 )
end

run Amc::App

