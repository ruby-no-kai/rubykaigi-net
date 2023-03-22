# config.ru
require 'himari'
require 'himari/aws'
require 'json'
require 'omniauth'
require 'omniauth-github'
require 'rack'
require 'rack/session/cookie'
require 'faraday'
require 'base64'
USER_AGENT = 'RubyKaigi-StaffIdP 1.0 (+https://rubykaigi.org)'

require 'aws-sdk-secretsmanager'
secret = JSON.parse(Aws::SecretsManager::Client.new().get_secret_value(secret_id: ENV.fetch('HIMARI_SECRET_PARAMS_ARN'), version_stage: 'AWSCURRENT').secret_string)

class ::CloudFrontViewerAddressToXff
  def initialize(app)
    @app = app
  end

  V6_REGEXP = /^([a-f0-9:]+):(\d+)$/

  def call(env)
    viewer = env['HTTP_CLOUDFRONT_VIEWER_ADDRESS']
    if viewer
      addr,port = if viewer.include?('.')
                    viewer.split(?:, 2)
                  else
                    viewer.downcase.match(V6_REGEXP)&.to_a[1,2]
                  end
      if addr && port
        env['HTTP_X_RACK_ORIG_X_FORWARDED_FOR'] = env['HTTP_X_FORWARDED_FOR'] if env['HTTP_X_FORWARDED_FOR']
        env['HTTP_X_RACK_ORIG_X_FORWARDED_PORT'] = env['HTTP_X_FORWARDED_FOR'] if env['HTTP_X_FORWARDED_PORT']
        env['HTTP_X_FORWARDED_FOR'] = addr
        env['HTTP_X_FORWARDED_PORT'] = port
      end
    end

    @app.call(env)
  end
end unless defined? ::CloudFrontViewerAddressToXff
use CloudFrontViewerAddressToXff

use(Rack::Session::Cookie,
  key: '__Host-himari-sess',
  path: '/',
  secure: true,
  expire_after: 3600 * 9,
  secret: secret.fetch('SECRET_KEY_BASE'),
)

use OmniAuth::Builder do
  # https://github.com/settings/applications/1979624 (sorah)
  provider :github, 'ebbaee63436735e33573', secret.fetch('GITHUB_CLIENT_SECRET'), scope: 'user,read:org'
end

use(Himari::Middlewares::Config,
  issuer: 'https://idp.rubykaigi.net',
  providers: [
    { name: :github, button: 'Log in with GitHub' },
  ],
  storage: Himari::Aws::DynamodbStorage.new(table_name: ENV.fetch('HIMARI_DYNAMODB_TABLE')),
  custom_messages: {
    title: 'KaigiAuth: Login',
    footer: <<~EOH,
       <p>
        <small>
          Powered by <a href="https://github.com/sorah/himari">sorah/himari</a> | <a href="https://github.com/ruby-no-kai/rubykaigi-nw/tree/master/tf/himari">Deployment</a>
        </small>
      </p>
    EOH
  },
  release_fragment: [
    ("r.#{File.read(File.join(ENV['LAMBDA_TASK_ROOT'] || '/', 'app', 'REVISION')).chomp}" rescue "r-"),
    ("c.#{Base64.urlsafe_encode64(Base64.decode64(ENV.fetch('HIMARI_RACK_DIGEST')), padding: false)}" rescue "c-"),
  ].join(?:),
)

use(Himari::Aws::SecretsmanagerSigningKeyProvider, 
  secret_id: ENV.fetch('HIMARI_SIGNING_KEY_ARN'),
  group: nil,
  kid_prefix: 'asm1',
)

#### CLIENTS SET

use(Himari::Middlewares::Client,
  name: 'testlb',
  id: 'testlb',
  secret: 'testlbsecret',
  redirect_uris: %w(https://test-lb.rubykaigi.net/oauth2/idpresponse),
)
#use(Himari::Middlewares::Client,
#  name: 'awsalb',
#  id: '...',
#  secret_hash: '...', # Digest::SHA384.hexdigest of actual secret
#  redirect_uris: %w(https://app.example.net/oauth2/idpresponse),
#)

#### CLAIMS RULE: GitHub

use(Himari::Middlewares::ClaimsRule, name: 'github-initialize') do |context, decision|
  next decision.skip!("provider not in scope") unless context.provider == 'github'

  decision.initialize_claims!(
    sub: "github_#{context.auth[:uid]}",
    name: context.auth[:info][:nickname],
    preferred_username: context.auth[:info][:nickname],
    email: context.auth[:info][:email],
  )
  decision.user_data[:provider] = 'github'

  decision.continue!
end

gh_faraday = Faraday.new(url: 'https://api.github.com', headers: { 'User-Agent' => USER_AGENT }) do |b|
  b.response :json
  b.response :raise_error
end
use(Himari::Middlewares::ClaimsRule, name: 'github-oauth-teams') do |context, decision|
  next decision.skip!("provider not in scope") unless context.provider == 'github'

  # https://docs.github.com/en/rest/teams/teams?apiVersion=2022-11-28#list-teams-for-the-authenticated-user
  # (not available in GitHub Apps = only available in OAuth apps)
  user_teams_resp = begin
    gh_faraday.get('user/teams', {per_page: 100}, { 'Accept' => 'application/vnd.github+json', 'Authorization' => "Bearer #{context.auth[:credentials][:token]}" }).body
  rescue Faraday::ResourceNotFound => e
    []
  end

  teams_in_scope = [
    'ruby-no-kai/rk-noc',
    'ruby-no-kai/rko-infra',
    %r{\Aruby-no-kai/rk\d+-orgz\z},
  ]
  teams = user_teams_resp
    .map { |team| "#{team.fetch('organization').fetch('login')}/#{team.fetch('slug')}" }
    .select { |login_slug| teams_in_scope.any? { |s| s === login_slug } }

  next decision.skip!("no teams in scope") if teams.empty?

  # claims
  decision.claims[:groups] ||= []
  decision.claims[:groups].concat(teams)
  decision.claims[:groups].uniq!

  decision.continue!
end

#### AUTHN RULE

use(Himari::Middlewares::AuthenticationRule, name: 'allow-github-with-teams') do |context, decision|
  next decision.skip!("provider not in scope") unless context.provider == 'github'

  if context.claims[:groups] && !context.claims[:groups].empty?
    next decision.allow!
  end

  decision.skip!("no available groups")
end


#### AUTHZ RULE

use(Himari::Middlewares::AuthorizationRule, name: 'default') do |context, decision|
  decision.allowed_claims.push(:groups)

  available_for_everyone = %w(
    wiki
    testlb
  )

  if available_for_everyone.include?(context.client.name)
    next decision.allow! 
  end

  decision.skip!
end

run Himari::App

