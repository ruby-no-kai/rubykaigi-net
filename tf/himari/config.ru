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
require 'apigatewayv2_rack'
USER_AGENT = 'RubyKaigi-StaffIdP 1.0 (+https://rubykaigi.org)'

require 'aws-sdk-secretsmanager'
secret = JSON.parse(Aws::SecretsManager::Client.new().get_secret_value(secret_id: ENV.fetch('HIMARI_SECRET_PARAMS_ARN'), version_stage: 'AWSCURRENT').secret_string)

use Apigatewayv2Rack::Middlewares::CloudfrontXff

use(Himari::Middlewares::Config,
  issuer: 'https://idp.rubykaigi.net',
  providers: [
    { name: :github, button: 'Log in with GitHub' },
  ],
  storage: Himari::Aws::DynamodbStorage.new(table_name: ENV.fetch('HIMARI_DYNAMODB_TABLE')),
  custom_messages: {
    title: 'KaigiStaff Login',
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

use Rack::CommonLogger

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
use(Himari::Middlewares::Client,
  name: 'amc',
  id: '87a353c4-f268-4399-ade3-de8f06cbc172',
  secret_hash: 'f6d8f4422bb0e7c0443cbe85cc4ef4e1b5f23c7efe76dfe1d87f7de793a7082701df5a8d08f446bb04ec1e07520474cd', # sha384.hexdigest
  redirect_uris: %w(https://amc.rubykaigi.net/auth/himari/callback),
)
use(Himari::Middlewares::Client,
  name: 'ops-lb',
  id: 'be906815-f319-8c1c-5078-b6ceed8cd57e',
  secret_hash: '3fcd566d9a8313e3fd120adf7a15fb29824413c3dfa1bfc36b20a8935699ff3afc8605761e4dd9d39ed40092e84fab64', # sha384.hexdigest
  redirect_uris: %w(
    https://test.rubykaigi.net/oauth2/idpresponse
    https://wlc.rubykaigi.net/oauth2/idpresponse
    https://prometheus.rubykaigi.net/oauth2/idpresponse
    https://alertmanager.rubykaigi.net/oauth2/idpresponse
    https://grafana.rubykaigi.net/oauth2/idpresponse
  ),
)

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
    'ruby-no-kai/rk-aws-admin',
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
use(Himari::Middlewares::AuthorizationRule, name: 'amc-github') do |context, decision|
  next decision.skip!('client not in scope') unless context.client.name == 'amc'
  next decision.skip!('provider not in scope') unless context.user_data[:provider] == 'github'

  groups = decision.claims.dig(:groups)
  roles = []

  if groups.include?('ruby-no-kai/rk-aws-admin')
    roles.push('arn:aws:iam::005216166247:role/OrgzAdmin') 
  end
  if groups.include?('ruby-no-kai/rk-noc')
    roles.push('arn:aws:iam::005216166247:role/NocAdmin') 
  end
  if groups.include?('ruby-no-kai/rk-orgz') || groups.include?('ruby-no-kai/rk23-orgz')
    roles.push('arn:aws:iam::005216166247:role/KaigiStaff')
  end

  decision.claims[:roles] = roles
  decision.allowed_claims.push(:roles)

  unless roles.empty?
    next decision.allow!
  end

  decision.skip!('no roles assigned')
end

run Himari::App

