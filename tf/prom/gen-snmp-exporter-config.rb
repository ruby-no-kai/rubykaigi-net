#!/usr/bin/env ruby

require 'json'
require 'tempfile'
require 'pathname'

TAG = 'rk-snmp-exporter-config-generator'

Dir.chdir __dir__

system(
  {'DOCKER_BUILDKIT' => '1'},
  'docker', 'build', '-qt', TAG,
  'snmp-exporter-config-generator',
  exception: true,
)

Tempfile.open do |jsonnet|
  system(
    'jsonnet', './snmp-exporter.config/config.jsonnet',
    out: jsonnet,
    exception: true,
  )

  system(
    'docker', 'run', '--rm', '-i', TAG, 'generate',
    in: jsonnet.tap(&:rewind),
    out: './gen/snmp.yml',
    exception: true,
  )
end
