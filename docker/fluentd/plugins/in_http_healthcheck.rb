module Fluent::Plugin
  class HttpHealthCheckInput < Input
    Fluent::Plugin.register_input('http_healthcheck', self)
    helpers :http_server

    desc 'The address to bind to.'
    config_param :bind, :string, default: '0.0.0.0'
    desc 'The port to listen to.'
    config_param :port, :integer, default: 8080

    CONTENT_TYPE_TEXT_PLAIN = { 'Content-Type' => 'text/plain' }.freeze

    def start
      super

      log.info "healthcheck endpoint at http://#{@bind}:#{@port}/healthz"

      http_server_create_http_server(
        :in_http_healthcheck_helper,
        addr: @bind,
        port: @port,
        logger: log,
      ) do |serv|
        serv.get('/healthz') do
          if healthy?
            [200, CONTENT_TYPE_TEXT_PLAIN, ['ok']]
          else
            [500, CONTENT_TYPE_TEXT_PLAIN, ['not ok']]
          end
        end
      end
    end

    private

    def healthy?
      # TODO: check workers in multi-worker mode
      true
    end
  end
end
