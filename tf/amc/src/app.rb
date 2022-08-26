require 'bundler/setup'
require 'aws-sdk-core' # sts
require 'aws-sdk-secretsmanager'
require 'json'
require 'jwt'
require 'erb'
require 'open-uri'
require 'openssl'
require 'faraday'
require 'digest/sha2'

module ElbPublicKeys
  def self.cache
    @cache ||= {}
  end

  def self.find(kid)
    cache[kid] ||= URI.open("https://public-keys.auth.elb.#{ENV.fetch('AWS_REGION')}.amazonaws.com/#{kid}", 'r', &:read).then do |pem|
      OpenSSL::PKey::EC.new(pem, '')
    end
  end
end

class Amc
  Request = Struct.new(:method, :path, :query, :headers, :body, :request_id, :function_arn, :function_version, keyword_init: true) do
    def self.from_alb_event(event, context)
      body = event['isBase64Encoded'] ? event.fetch('body').unpack1('m*') : event.fetch('body', '')
      new(
        method: event.fetch('httpMethod'),
        path: event.fetch('path'),
        query: event.fetch('queryStringParameters', {}),
        headers: event.fetch('headers'),
        request_id: context.aws_request_id,
        function_arn: context.invoked_function_arn,
        function_version: context.function_version,
        body: body,
      )
    end

    def content_type
      headers['content-type']
    end

    def xff
      headers['x-forwarded-for']
    end

    def user_agent
      headers['user-agent']
    end

    def json
      raise Error.new(400, 'not a json request') unless content_type&.match?(%r{\Aapplication/json(?:;.*)?\z})
      @json ||= JSON.parse(body)
    rescue JSON::ParserError => e
      raise Error.new(400, e.inspect)
    end
  end

  Response = Struct.new(:status, :headers, :body, :meta, keyword_init: true) do
    def as_json
      {
        'statusCode' => status,
        'statusDescription' => {
          200 => '200 OK',
          302 => '302 Found',
          400 => '400 Bad Request',
          401 => '401 Unauthorized',
          410 => '410 Gone',
          404 => '404 Not Found',
          500 => '500 Internal Server Error',
        }.fetch(status),
        'headers' => headers,
        'body' => body,
        'isBase64Encoded' => false,
      }
    end
  end


  class Error < StandardError
    def initialize(code, message)
      super(message)
      @code = code
    end

    def as_response
      Response.new(status: code, headers: { 'content-type' => 'application/json; charset=utf-8' }, body: "#{JSON.generate({ok: false, error: {code: code, message: message}})}\n", meta: {error: self.inspect, cause: self.cause&.inspect})
    end

    attr_reader :code
  end

  def initialize(request)
    @request = request
    @meta = {}
  end

  attr_reader :request, :user

  def respond
    begin
      begin
        ta = Time.now
        respond_inner()
      rescue NoMemoryError, ScriptError, SecurityError, SignalException, SystemExit, SystemStackError => e
        raise e
      rescue Error => e
        raise e
      rescue Exception => e
        $stderr.puts e.full_message
        raise Error.new(500, 'Internal Server Error')
      end
    rescue Error => e
      e.as_response
    end.tap do |response|
      puts JSON.generate(
       status: response.status,
        method: request.method,
        path: request.path,
        query: request.query.reject { |k,v| k.start_with?('secure_') },
        reqtime: Time.now.to_f - ta.to_f,
        xff: request.xff,
        ua: request.user_agent,
        login: user&.then { |v| {username: v['preferred_username'], email: v['email'], sub: v['sub']} },
        meta: @meta.merge(response.meta || {}),
        ver: request.function_version,
        rev: revision_file,
      )
    end.as_json
  end

  def respond_inner
    case [request.method, request.path]
    when ['GET', '/']
      authorize!
      handle_top

    when ['POST', '/api/signin']
      authorize!
      ensure_x_requested_with!
      handle_signin

    when ['POST', '/api/creds']
      authorize!
      ensure_x_requested_with!
      handle_credentials

    when ['GET', '/public/snip']
      handle_snippet_decrypt

    when ['GET', '/.well-known/openid-configuration']
      handle_oidc_discovery

    when ['GET', '/public/jwks']
      handle_jwks

    else
      case
      when request.method == 'GET' && request.path.start_with?('/public/')
        handle_assets
      else
        Error.new(404, 'not found').as_response
      end
    end
  end

  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/listener-authenticate-users.html#user-claims-encoding
  def authorize!
    jwt_data = request.headers['x-amzn-oidc-data']
    raise Error.new(401, 'no JWT provided') unless jwt_data
    token = JWT.decode(jwt_data, nil, true, { iss: ENV.fetch('AMC_EXPECT_ISS').split(?\n), verify_iss: true, algorithm: 'ES256' }) do |header, payload|
      ElbPublicKeys.find(header.fetch('kid'))
    rescue KeyError
      raise Error.new(401, 'JWT has no kid !?')
    end

    @user = token[0]
    @jwt = token
  rescue JWT::DecodeError
    raise Error.new(401, 'JWT::DecodeError')
  end

  def ensure_x_requested_with!
    if request.headers['x-requested-with'] != 'amc-client'
      raise Error.new(403, 'x-requested-with')
    end
  end

  def handle_top
    Response.new(
      status: 200,
      headers: {
        'content-type' => 'text/html; charset=utf-8',
      },
      body: ERB.new(File.read(File.join(__dir__, 'index.html.erb'))).result(binding),
    )
  end

  def handle_signin
    Response.new(
      status: 200,
      headers: {
        'cache-control' => 'no-cache,no-store,max-age=0',
        'content-type' => 'application/json; charset=utf-8',
      },
      body: JSON.generate(
        ok: true,
        signin_token: signin_token(),
        preferred_region: ENV.fetch('AWS_REGION', 'us-east-1'),
      )
    )
  end

  def handle_credentials
    assume = assume_role()

    Response.new(
      status: 200,
      headers: {
        'cache-control' => 'no-cache,no-store,max-age=0',
        'content-type' => 'application/json; charset=utf-8',
      },
      body: JSON.generate(
        ok: true,
        preferred_region: ENV.fetch('AWS_REGION', 'us-east-1'),
        assume_role_response: assume.to_h,
        envchain_snippet_url: generate_snippet(generate_envchain_text(assume), expires_in: 300),
      )
    )
  end

  def handle_oidc_discovery
    Response.new(
      status: 200,
      headers: {
        # 'cache-control' => 'public, max-age=3600',
        'content-type' => 'application/json; charset=utf-8',
      },
      body: JSON.generate(
        issuer: ENV.fetch('AMC_SELF_ISS'),
        jwks_uri: "#{ENV.fetch('AMC_SELF_ISS')}/public/jwks",
        response_types_supported: %w(id_token),
        subject_types_supported: %w(public),
        claims_supported: %w(sub iss iat nbf exp),
        id_token_signing_alg_values_supported: %w(RS256),
      ),
    )
  end

  def handle_jwks
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

    Response.new(
      status: 200,
      headers: {
        # 'cache-control' => 'public, max-age=3600',
        'content-type' => 'application/json; charset=utf-8',
      },
      body: JSON.generate(
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
      ),
    )
  end

  def handle_assets
    path = File.join(__dir__, request.path.gsub(/\.+\//,''))
    realpath = File.realpath(path)
    raise Error.new(404, '') unless realpath.start_with?(File.realpath(File.join(__dir__, 'public/')))
    body = File.read(realpath)
    content_type = case realpath
                   when /\.css$/; 'text/css; charset=utf-8'
                   when /\.js$/; 'application/javascript; charset=utf-8'
                   else
                     'application/octet-stream'
                   end
    Response.new(
      status: 200,
      headers: {
        'cache-control' => 'public, max-age=604800',
        'content-type' => content_type,
      },
      body: body,
      meta: {realpath: realpath},
    )
  rescue Errno::ENOENT
    raise Error.new(404, 'not found')
  end

  Snippet = Struct.new(:exp, :ty, :b, keyword_init: true)
  SnippetEnvelope = Struct.new(:k, :exp, :iv, :tag, :ct, keyword_init: true)
  class ExpiredSnippetError < StandardError; end
  class InvalidSnippetError < StandardError; end

  def handle_snippet_decrypt
    secure_data = request.query['secure_data'] or raise Error.new(400, 'no secure_data')
    envelope = decrypt_snippet(secure_data)
    Response.new(
      status: 200,
      headers: {
        'cache-control' => 'no-store,no-cache,max-age=0',
        'content-type' => envelope.ty,
      },
      body: envelope.b,
    )
  rescue ExpiredSnippetError
    raise Error.new(410, 'expired')
  rescue InvalidSnippetError
    raise Error.new(400, 'invalid')
  end

  private def generate_snippet(body, content_type: 'text/plain; charset=utf-8', expires_in:)
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
      iv: Base64.urlsafe_encode64(iv),
      k: Base64.urlsafe_encode64(current_signing_key[1].public_encrypt(data_key)),
      tag: Base64.urlsafe_encode64(cipher.auth_tag),
      ct: Base64.urlsafe_encode64(ciphertext),
    ).to_h)

    "#{ENV.fetch('AMC_SELF_ISS')}/public/snip?secure_data=#{URI.encode_www_form_component(Base64.urlsafe_encode64(data).sub(/=+$/,''))}"
  end

  private def decrypt_snippet(secure_data)
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

  private def assume_role
    username = (user['preferred_username'] || user['email']) or raise "cannot determine username, available keys: #{user.keys.inspect}"
    iat = Time.new
    payload = {
      iss: ENV.fetch('AMC_SELF_ISS'),
      aud: 'sts.amazonaws.com',
      sub: user.fetch('sub'),
      preferred_username: username,
      jti: Digest::SHA256.hexdigest("#{request.function_arn}\n#{request.function_version}\n#{request.request_id}\n"),
      iat: iat.to_i,
      nbf: iat.to_i,
      exp: (iat+300).to_i,
      TransitiveTagKeys: {
        AmcRequestId: request.request_id,
        AmcRequestIp: request.xff,
      },
    }
    kid, pkey = current_signing_key
    jwt = JWT.encode(payload, pkey, 'RS256', { kid: kid })

    @meta[:jwt_jti] = payload.fetch(:jti)
    @meta[:jwt_user] = username

    sts = Aws::STS::Client.new
    resp = sts.assume_role_with_web_identity(
      duration_seconds: ENV.fetch('AMC_SESSION_DURATION', 3600),
      role_arn: ENV.fetch('AMC_ROLE_ARN'),
      role_session_name: username,
      web_identity_token: jwt,
    )

    @meta[:assumed_aki] = resp.assumed_role_user.assumed_role_id
    @meta[:assumed_ari] = resp.credentials.access_key_id

    resp
  end

  private def signin_token
    http = Faraday.new() do |builder|
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

  private def secretsmanager
    @secretsmanager ||= Aws::SecretsManager::Client.new()
  end

  private def cachebuster
    @cachebuster ||= Digest::SHA256.hexdigest("#{request.function_arn}\n#{request.function_version}\n#{revision_file}\n")
  end

  private def revision_file
    @revision_file ||= File.read(File.join(__dir__, 'REVISION')).chomp
  rescue Errno::ENOENT
    nil
  end
end

def handler(event:, context:)
  Amc.new(Amc::Request.from_alb_event(event, context)).respond
end
