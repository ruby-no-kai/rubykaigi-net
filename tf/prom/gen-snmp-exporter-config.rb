#!/usr/bin/env ruby

require 'json'
require 'tempfile'
require 'pathname'

Dir.chdir __dir__

system(
  'docker', 'build', '-qt', 'snmp-exporter-config-generator',
  '../../docker/snmp-exporter-config-generator',
  exception: true,
)

Tempfile.open do |jsonnet|
  system(
    'jsonnet ./snmp-exporter.generator.jsonnet',
    out: jsonnet,
    exception: true,
  )

  system(
    'docker', 'run', '--rm', '-i', 'snmp-exporter-config-generator',
    in: jsonnet.tap(&:rewind),
    out: './gen/snmp.yml',
    exception: true,
  )
end
