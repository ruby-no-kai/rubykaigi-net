require_relative './common'
require 'apigatewayv2_rack'
require 'openssl'
require 'rack'
require 'rack/utils'
require 'sinatra/base'

class Inbound
  include Common

  def respond
    req = Apigatewayv2Rack::Request.new(event, context)
    env = req.to_h
    env['rk.task'] = self
    status, headers, body = App.call(env)
    Apigatewayv2Rack::Response.new(status: status, headers: headers, body: body, elb: req.elb?, multivalued: req.multivalued?).as_json
  end

  class App < Sinatra::Base
    helpers do
      def sqs
        env.fetch('rk.task').sqs
      end

      def sqs_queue_url
        env.fetch('rk.task').sqs_queue_url
      end

      def secret
        env.fetch('rk.task').secret
      end
    end

    post '/webhook' do
      body = request.body.tap(&:rewind).read

      shared_secret = secret.fetch(:front_webhook_secret)
      given_signature = (request.env['HTTP_X_FRONT_SIGNATURE'] || '').unpack1('m*')
      signature = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha1'), shared_secret, body)
      unless Rack::Utils.secure_compare(signature, given_signature)
        warn "signature mismatch: given=#{given_signature.inspect}, expected:#{signature.inspect}"
        halt 401, "unauthorized"
      end

      payload = JSON.parse(body)

      puts(JSON.generate(ok: true, payload: payload))
      sqs.send_message(
        queue_url: sqs_queue_url,
        message_body: JSON.generate(kind: 'webhook_payload', payload: payload),
      )

      content_type :json
      "{\"ok\": true}\n"
    end
  end
end

def handler(event:, context:)
  Inbound.new(event, context).respond
end
