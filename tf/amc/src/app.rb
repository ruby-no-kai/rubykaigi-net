require 'time'
require 'logger'
require 'sinatra/base'
require 'aws-sdk-core' # sts
require 'aws-sdk-secretsmanager'
require 'json'
require 'jwt'
require 'open-uri'
require 'openssl'
require 'faraday'
require 'digest/sha2'

module Amc
  class App < Sinatra::Base
    USER_AGENT = "RubyKaigi-Amc 2.0 (+https://github.com/rubykaigi/rubykaigi-nw)"
    Snippet = Struct.new(:exp, :ty, :b, keyword_init: true)
    SnippetEnvelope = Struct.new(:k, :exp, :iv, :tag, :ct, keyword_init: true)
    class ExpiredSnippetError < StandardError; end
    class InvalidSnippetError < StandardError; end

    set :root, File.expand_path(File.join(__dir__))

    # authenticity_token: use x-requested-with header for APIs
    # json_csrf: can be prevented using x-content-type-options:nosniff
    # http_origin: does not respect x-f-h
    set :protection, except: %i(authenticity_token remote_token json_csrf http_origin)

    set(:auth) do |flag|
      condition do
        case flag
        when true
          unless current_user
            next redirect('/auth/himari', 302)
          end
        when :api
          next halt(403, 'x-requested-with') unless env['HTTP_X_REQUESTED_WITH'] == 'amc-client'
          unless current_user
            next halt(401, 'Login session required')
          end
        end
      end
    end

    helpers do
      def lambda_context
        @lambda_context ||= env['apigatewayv2.request']&.context
      end

      def log(message, **data)
        context = lambda_context
        puts(JSON.generate(
          time: Time.now.xmlschema,
          message: message,
          req: {
            method: request.request_method,
            path: request.path,
            query: request.query_string,
            request_id: context&.aws_request_id,
            function_arn: context&.invoked_function_arn,
            function_version: context&.function_version,
            ip: request.ip,
            xff: env['HTTP_X_FORWARDED_FOR'],
            cip: env['REMOTE_ADDR'],
          },
          user: current_user&.then do |user|
            {
              sub: user.dig(:claims, 'sub'),
              email: user.dig(:claims, 'email'),
              username: user.dig(:claims, 'preferred_username'),
              jti: user.dig(:claims, 'jti'),
              iat: user.dig(:claims, 'iat'),
              exp: user.dig(:claims, 'exp'),
            }
          end,
          data: data,
        ))
      end

      def json
        @json ||= JSON.parse(request.body.tap(&:rewind).read)
      rescue JSON::ParserError
        halt 400, 'JSON::ParserError'
      end

      def current_user
        if session[:user]
          @current_user ||= begin
            user = session[:user]
            claims = user[:claims]
            if claims[:exp] <= Time.now.to_i
              warn "Session expired"
              session[:user] = nil 
            end
            session[:user]
          end
        end
      end

      def current_user_userinfo
        return nil unless current_user
        return @current_user_userinfo if defined? @current_user_userinfo

        http = Faraday.new(url: ENV.fetch('AMC_EXPECT_ISS'), headers: {'User-Agent' => USER_AGENT, 'Authorization' => "Bearer #{current_user[:token]}"}) do |builder|
          builder.response :json
          builder.response :raise_error
          builder.adapter :net_http
        end
        log('Userinfo: Checking')
        @current_user_userinfo = http.get("public/oidc/userinfo").body
      rescue Faraday::UnauthorizedError
        log('Userinfo: Unauthorized')
        halt 401, 'Token Expired'
      end

      def generate_snippet(body, content_type: 'text/plain; charset=utf-8', expires_in:)
        exp = Time.now.to_i + expires_in
        inner = JSON.generate(Snippet.new(exp: exp, ty: content_type, b: body).to_h)

        cipher = OpenSSL::Cipher.new('aes-256-gcm')
        data_key = OpenSSL::Random.random_bytes(cipher.key_len)
        cipher.encrypt
        cipher.key = data_key
        cipher.iv = iv = cipher.random_iv
        cipher.auth_data = ''

        ciphertext = cipher.update(inner)
        ciphertext << cipher.final

        data = JSON.generate(SnippetEnvelope.new(
          exp: exp,
          iv: Base64.urlsafe_encode64(iv, padding: false),
          k: Base64.urlsafe_encode64(current_signing_key[1].public_encrypt(data_key), padding: false),
          tag: Base64.urlsafe_encode64(cipher.auth_tag, padding: false),
          ct: Base64.urlsafe_encode64(ciphertext, padding: false),
        ).to_h)

        {
          url: "#{ENV.fetch('AMC_SELF_ISS')}/public/snip",
          data: "secure_data=#{URI.encode_www_form_component(Base64.urlsafe_encode64(data, padding: false))}",
        }
      end

      def decrypt_snippet(secure_data)
        envelope_data = JSON.parse(
          Base64.urlsafe_decode64(secure_data),
          symbolize_names: true,
        )
        raise InvalidSnippetError unless envelope_data.is_a?(Hash)
        envelope = SnippetEnvelope.new(envelope_data)

        raise ExpiredSnippetError if envelope.exp < Time.now.to_i

        data_key = current_signing_key[1].private_decrypt(Base64.urlsafe_decode64(envelope.k))

        cipher = OpenSSL::Cipher.new('aes-256-gcm').tap do |c|
          c.decrypt
          c.key = data_key
          c.iv = Base64.urlsafe_decode64(envelope.iv)
          c.auth_data = ''
          c.auth_tag = Base64.urlsafe_decode64(envelope.tag)
        end

        cleartext = cipher.update(Base64.urlsafe_decode64(envelope.ct))
        cleartext << cipher.final
        inner_data = JSON.parse(cleartext, symbolize_names: true)
        raise InvalidSnippetError unless inner_data.is_a?(Hash)
        inner = Snippet.new(inner_data)
        raise ExpiredSnippetError if inner.exp < Time.now.to_i

        inner
      rescue OpenSSL::Cipher::CipherError, ArgumentError => e
        puts "invalid encrypted snippet: #{e.full_message}"
        raise InvalidSnippetError
      end

      private def generate_envchain_text(assume)
        [
          assume.credentials.access_key_id,
          assume.credentials.secret_access_key,
          assume.credentials.session_token,
          ''
        ].join("\n")
      end

      private def current_signing_key
        @current_signing_key ||= begin
          secret = secretsmanager.get_secret_value(secret_id: ENV.fetch('AMC_SIGNING_KEY_ARN'), version_stage: 'AWSCURRENT')
          value = JSON.parse(secret.secret_string)
          [secret.version_id, OpenSSL::PKey::RSA.new(value.fetch('rsa').fetch('pem'), '')]
        end
      end

      private def assume_role(role_arn: json['role_arn'])
        claims = current_user_userinfo()
        possible_roles = claims['roles']
        raise 'cannot determine possible roles' if !possible_roles || !possible_roles.is_a?(Array)
        username = (claims['preferred_username'] || claims['email']) or raise "cannot determine username, available keys: #{claims.keys.inspect}"
        return halt(403, 'forbidden role') unless possible_roles.include?(role_arn)

        iat = Time.new
        payload = {
          iss: ENV.fetch('AMC_SELF_ISS'),
          aud: 'sts.amazonaws.com',
          sub: "#{role_arn.split(?/).last}:#{claims.fetch('sub')}",
          preferred_username: username,
          jti: Digest::SHA256.hexdigest("#{lambda_context.invoked_function_arn}\n#{lambda_context.function_version}\n#{lambda_context.aws_request_id}\n"),
          iat: iat.to_i,
          nbf: iat.to_i,
          exp: (iat+300).to_i,
          TransitiveTagKeys: {
            AmcRequestId: lambda_context.aws_request_id,
            AmcRequestIp: request.ip,
          },
        }
        kid, pkey = current_signing_key
        jwt = JWT.encode(payload, pkey, 'RS256', { kid: kid })

        log('Assuming role...', role_arn: role_arn, jwt_jti: payload.fetch(:jti), jwt_user: username)

        sts = Aws::STS::Client.new
        resp = sts.assume_role_with_web_identity(
          duration_seconds: ENV.fetch('AMC_SESSION_DURATION', 3600),
          role_arn: role_arn,
          role_session_name: username,
          web_identity_token: jwt,
        )

        log('Assumed role', role_arn: role_arn, jwt_jti: payload.fetch(:jti), jwt_user: username, assumed_aki: resp.assumed_role_user.assumed_role_id, assumed_ari: resp.credentials.access_key_id)

        resp
      end

      def signin_token
        http = Faraday.new(url: nil, headers: {'User-Agent' => USER_AGENT}) do |builder|
          builder.request :url_encoded
          builder.response :json
          builder.response :raise_error
          builder.adapter :net_http
        end

        assume = assume_role()
        session = {sessionId: assume.credentials.access_key_id, sessionKey: assume.credentials.secret_access_key, sessionToken: assume.credentials.session_token}
        resp = http.post("https://#{ENV.fetch('AWS_REGION', 'us-east-1')}.signin.aws.amazon.com/federation", {'Action' => 'getSigninToken', 'Session' => JSON.generate(session)})

        resp.body.fetch('SigninToken')
      end

      def secretsmanager
        @secretsmanager ||= Aws::SecretsManager::Client.new()
      end

      def cachebuster
        @cachebuster ||= Digest::SHA256.hexdigest("#{lambda_context.invoked_function_arn}\n#{lambda_context.function_version}\n#{revision_file}\n")
      end

      def revision_file
        @revision_file ||= File.read(File.join(__dir__, 'REVISION')).chomp
      rescue Errno::ENOENT
        nil
      end

    end

    get '/', auth: true do
      @assigned_roles = current_user.dig(:claims, 'roles') || []
      erb :index
    end

    get '/auth/himari/callback' do
      auth = env['omniauth.auth']
      halt 400, 'bad request (no auth)' unless auth
      halt 400, 'bad request (not himari)' unless auth['provider'] == 'himari'
      session[:user] = {
        claims: auth.dig('extra', 'raw_info'),
        token: auth.dig('credentials', 'token'),
      }
      log('logged in')
      redirect '/', 302
    end

    post '/api/signin', auth: :api do
      headers 'cache-control' => 'private,no-cache,no-store,max-age=0'
      content_type :json

      JSON.generate(
        ok: true,
        signin_token: signin_token(),
        preferred_region: ENV.fetch('AWS_REGION', 'us-east-1'),
      )
    end

    post '/api/creds', auth: :api do
      headers 'cache-control' => 'private,no-cache,no-store,max-age=0'
      content_type :json

      assume = assume_role()
      JSON.generate(
        ok: true,
        preferred_region: ENV.fetch('AWS_REGION', 'us-east-1'),
        assume_role_response: assume.to_h,
        envchain_snippet_url: generate_snippet(generate_envchain_text(assume), expires_in: 90),
      )
    end

    post '/public/snip' do
      secure_data = params[:secure_data] or raise Error.new(400, 'no secure_data')
      envelope = decrypt_snippet(secure_data)

      headers 'cache-control' => 'public,no-store,no-cache,max-age=0'
      content_type envelope.ty
      envelope.b

    rescue ExpiredSnippetError
      log('ExpiredSnippetError')
      halt 410, 'expired'
    rescue InvalidSnippetError
      log('InvalidSnippetError')
      halt 400, 'invalid'
    end

    get '/.well-known/openid-configuration' do
      content_type :json
      JSON.generate(
        issuer: ENV.fetch('AMC_SELF_ISS'),
        jwks_uri: "#{ENV.fetch('AMC_SELF_ISS')}/public/jwks",
        response_types_supported: %w(id_token),
        subject_types_supported: %w(public),
        claims_supported: %w(iss aud sub preferred_username jti iat nbf exp),
        id_token_signing_alg_values_supported: %w(RS256),
      )
    end

    get '/public/jwks' do
      keys = secretsmanager.describe_secret(secret_id: ENV.fetch('AMC_SIGNING_KEY_ARN'))
        .then { |secret|  [secret, secret.version_ids_to_stages.keys] }
        .then { |(secret, versions)| versions.map { |v| @secretsmanager.get_secret_value(secret_id: secret.arn, version_id: v) } }
        .then { |secrets|
          secrets.map do |s|
            [s.version_id, OpenSSL::PKey::RSA.new(JSON.parse(s.secret_string).fetch('rsa').fetch('pem'), '')]
          rescue JSON::ParserError, OpenSSL::PKey::RSAError, KeyError => e
            $stderr.puts "WARN: JWK - #{s.arn} (version=#{s.version_id}) contains invalid JSON #{e.inspect}"
            next
          end.compact
        }
      content_type :json
      JSON.generate(
        keys: keys.map do |(kid,key)|
          {
            kid: kid,
            use: "sig",
            kty: 'RSA',
            alg: 'RS256',
            n: Base64.urlsafe_encode64(key.n.to_s(2)).gsub(/=+/,''),
            e: Base64.urlsafe_encode64(key.e.to_s(2)).gsub(/=+/,''),
          }
        end,
      )
    end
  end
end
