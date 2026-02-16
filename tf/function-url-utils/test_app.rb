require 'rk_logger'
require 'apigatewayv2_rack'
require 'sinatra/base'

class TestApp
  def self.respond(event, context)
    req = Apigatewayv2Rack::Request.new(event, context)
    env = req.to_h
    status, headers, body = app.call(env)
    Apigatewayv2Rack::Response.new(status:, headers:, body:, elb: req.elb?, multivalued: req.multivalued?).as_json
  end

  def self.app
    @app ||= RkLogger::RackLogger.new(App)
  end

  class App < Sinatra::Base
    get "/" do
      content_type :json
      "{\"hello\": true}\n"
    end

    get "/errortown" do
      raise "Boom!"
    end
  end
end

def handler(event:, context:)
  TestApp.respond(event, context)
end
