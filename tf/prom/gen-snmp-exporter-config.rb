#!/usr/bin/env ruby

require 'json'
require 'tempfile'
require 'pathname'

Dir.chdir __dir__

system(
  {'DOCKER_BUILDKIT' => '1'},
  'docker', 'build', '-qt', 'snmp-exporter-config-generator',
  '../../docker/snmp-exporter-config-generator',
  exception: true,
)

Tempfile.open do |jsonnet|
  system(
    'jsonnet ./snmp-exporter-generator/config.jsonnet',
    out: jsonnet,
    exception: true,
  )

  system(
    'docker', 'run', '--rm', '-i', 'snmp-exporter-config-generator', 'generate',
    in: jsonnet.tap(&:rewind),
    out: './gen/snmp.yml',
    exception: true,
  )
end
