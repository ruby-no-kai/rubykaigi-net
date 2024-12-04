# config.ru
require 'himari'
require 'himari/aws'
require 'json'
require 'omniauth'
require 'omniauth-github'
require 'rack'
require 'rack/session/cookie'
require 'rack/cors'
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
  require_pkce: true,
)
use(Himari::Middlewares::Client,
  name: 'amc-local',
  id: 'd22e8760-2fc9-4e5e-ab71-12d6657dcc92',
  secret_hash: 'f6d8f4422bb0e7c0443cbe85cc4ef4e1b5f23c7efe76dfe1d87f7de793a7082701df5a8d08f446bb04ec1e07520474cd', # sha384.hexdigest
  redirect_uris: %w(http://localhost:3000/auth/himari/callback),
  require_pkce: true,
)
use(Himari::Middlewares::Client,
  name: 'amc-local2',
  id: 'a94519af-8c51-4f8b-af3a-a58130415096',
  secret_hash: 'b46b2dc7a429ebce84ad257d3bfab6608c40556e0384b7317a9d595c26fe813737749810bdfde5c62766d2750145d3a8', # sha384.hexdigest
  redirect_uris: %w(http://127.0.0.1:16252/oauth2callback http://[::1]:16252/oauth2callback),
  require_pkce: true,
)
use(Himari::Middlewares::Client,
  name: 'ops-lb',
  id: 'edfd99bd-b6a4-39ce-d2db-1e7b237295fd',
  secret_hash: '4d84461d3e428ca3303fc9b5b33209f1b18a4d54b6160c01ef43ecec5d987b223c40b27feb9577c7fa4056a219502611', # sha384.hexdigest
  # terraform output -json oidc_client | ruby -rdigest -rjson -e 'puts Digest::SHA384.hexdigest(JSON.parse($<.read)["secret"])'
  redirect_uris: %w(
    https://test.rubykaigi.net/oauth2/idpresponse
    https://wlc.rubykaigi.net/oauth2/idpresponse
    https://prometheus.rubykaigi.net/oauth2/idpresponse
    https://alertmanager.rubykaigi.net/oauth2/idpresponse
  ),
)
use(Himari::Middlewares::Client,
  name: 'grafana',
  id: 'bc0d7e96-8bd9-3fea-357c-aea827e4353b',
  secret_hash: '20582c92c1a1f5c2fdbb1fb88978d8b8e2217b5ea2fc701071770c21dbd1105d9f9968f1e3f5a19f7ab626c559c71ffa', # sha384.hexdigest
  redirect_uris: %w(
    https://grafana.rubykaigi.net/login/generic_oauth
  ),
)

use(Himari::Middlewares::Client,
  name: 'signage-prd',
  id: '13756142-32e6-4379-aad4-52f3501485bc',
  # rka tf output -json prd |jq .frontend_config.user_pool_client_secret | ruby -rdigest -rjson -e 'puts Digest::SHA384.hexdigest(JSON.parse($<.read).chomp)'
  secret_hash: '86be04b593685d35ab20804cacd0ed419bb74eea2aa539aa263c576b8509ab0b49a29b2b69b12bc03538184ad8f793f7',
  redirect_uris: %w(
    https://rk-signage-prd.auth.ap-northeast-1.amazoncognito.com/oauth2/idpresponse
  ),
)
use(Himari::Middlewares::Client,
  name: 'signage-dev',
  id: '689e0e73-c496-4269-b06c-28ee7d932cee',
  # terraform output dev_oidc_client_secret | ruby -rdigest -rjson -e 'puts Digest::SHA384.hexdigest(JSON.parse($<.read).chomp)'
  secret_hash: '963980c42c674de2397aab655a3e51eaa02ca572ea5721afff54012974c9c333b6ea1babd828d75388681260b9467aed',
  redirect_uris: %w(
    https://rk-signage-dev.auth.ap-northeast-1.amazoncognito.com/oauth2/idpresponse
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

    'kaigionrails/infra',
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
    ops-lb
  )

  if available_for_everyone.include?(context.client.name)
    decision.lifetime = 3600 * 12
    next decision.allow!
  end

  decision.skip!
end

use(Himari::Middlewares::AuthorizationRule, name: 'grafana') do |context, decision|
  next decision.skip!('client not in scope') unless context.client.name == 'grafana'
  next decision.skip!('provider not in scope') unless context.user_data[:provider] == 'github'

  groups = decision.claims.dig(:groups)
  roles = []

  if groups.include?('ruby-no-kai/rk-noc')
    roles.push('admin')
  else
    roles.push('viewer')
  end

  decision.claims[:roles] = roles
  decision.allowed_claims.push(:roles)

  unless roles.empty?
    decision.lifetime.access_token = 3600 * 12
    decision.lifetime.id_token = 3600 * 12
    next decision.allow!
  end

  decision.skip!
end

use(Himari::Middlewares::AuthorizationRule, name: 'amc-github') do |context, decision|
  next decision.skip!('client not in scope') unless context.client.name == 'amc' || context.client.name == 'amc-local' || context.client.name == 'amc-local2'
  next decision.skip!('provider not in scope') unless context.user_data[:provider] == 'github'

  groups = decision.claims.dig(:groups)
  roles = []

  if groups.include?('ruby-no-kai/rk-aws-admin')
    roles.push('arn:aws:iam::005216166247:role/OrgzAdmin') 
    roles.push('arn:aws:iam::005216166247:role/SponsorAppDev') 
  end
  if groups.include?('ruby-no-kai/rk-noc')
    roles.push('arn:aws:iam::005216166247:role/NocAdmin') 
    roles.push('arn:aws:iam::005216166247:role/SponsorAppDev') 
  end
  if groups.include?('ruby-no-kai/rk-orgz') || groups.include?('ruby-no-kai/rk24-orgz')
    roles.push('arn:aws:iam::005216166247:role/KaigiStaff')
    roles.push('arn:aws:iam::005216166247:role/SponsorAppDev') 
  end

  if groups.include?('kaigionrails/infra')
    roles.push('arn:aws:iam::861452569180:role/OrganizationAccountAccessRole')
  end

  decision.claims[:roles] = roles.uniq
  decision.allowed_claims.push(:roles)

  unless roles.empty?
    next decision.allow!
  end

  decision.skip!('no roles assigned')
end

use(Himari::Middlewares::AuthorizationRule, name: 'signage-app') do |context, decision|
  next decision.skip!('client not in scope') unless context.client.name == 'signage-dev' || context.client.name == 'signage-prd'
  next decision.skip!('provider not in scope') unless context.user_data[:provider] == 'github'

  groups = decision.claims.dig(:groups)
  role = []

  if groups.include?('ruby-no-kai/rk-noc')
    role ||= :admin
  end
  if groups.include?('ruby-no-kai/rk-orgz') || groups.include?('ruby-no-kai/rk24-orgz')
    role ||= :admin
  end

  decision.claims[:role] = role
  decision.allowed_claims.push(:role)

  if role
    decision.lifetime.access_token = 3600 * 20
    decision.lifetime.id_token = 3600 * 20
    next decision.allow!
  end

  decision.skip!('no roles assigned')
end



run Himari::App

