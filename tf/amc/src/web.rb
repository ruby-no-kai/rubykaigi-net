require 'bundler/setup'
require 'apigatewayv2_rack'

Main = Apigatewayv2Rack.handler_from_rack_config_file(File.join(__dir__, 'config.ru'))
