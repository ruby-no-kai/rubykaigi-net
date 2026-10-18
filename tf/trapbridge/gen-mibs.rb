#!/usr/bin/env ruby

require 'fileutils'
require 'tmpdir'
require 'tempfile'

MIBS_TAG = 'rk-snmp-exporter-config-generator'
TAG = 'rk-trapbridge-mib-dump'
OUTPUT = '../../k8s/trapbridge/config/mibs.json'
# ConfigMap data is limited to 1 MiB in total, shared with config.json.
MAX_SIZE = 900 * 1024
MIB_DIRS = %w[/usr/share/snmp/mibs /var/lib/mibs]

Dir.chdir __dir__

system(
  {'DOCKER_BUILDKIT' => '1'},
  'docker', 'build', '-q', '--load', '-t', MIBS_TAG,
  '../prom/snmp-exporter-config-generator',
  exception: true,
)

# A docker-container builder cannot see local images, so MIBS_TAG is passed in as a directory context.
Dir.mktmpdir('rk-trapbridge-mibs') do |mibs_root|
  container = IO.popen(['docker', 'create', MIBS_TAG], &:read).chomp
  raise "docker create #{MIBS_TAG} failed" unless $?.success?
  begin
    MIB_DIRS.each do |dir|
      FileUtils.mkdir_p(File.join(mibs_root, File.dirname(dir)))
      system('docker', 'cp', '-q', "#{container}:#{dir}", File.join(mibs_root, dir), exception: true)
    end
  ensure
    system('docker', 'rm', container, out: File::NULL, exception: true)
  end

  system(
    {'DOCKER_BUILDKIT' => '1'},
    'docker', 'build', '-q', '--load', '-t', TAG,
    '--build-context', "#{MIBS_TAG}=#{mibs_root}",
    'mib-dump',
    exception: true,
  )
end

FileUtils.mkdir_p(File.dirname(OUTPUT))

Tempfile.open do |jsonnet|
  system(
    'jsonnet', './mib-dump.config/config.jsonnet',
    out: jsonnet,
    exception: true,
  )

  Tempfile.create(['mibs', '.json'], File.dirname(OUTPUT)) do |out|
    system(
      'docker', 'run', '--rm', '-i', TAG,
      in: jsonnet.tap(&:rewind),
      out:,
      exception: true,
    )
    out.close

    size = File.size(out.path)
    abort "#{OUTPUT}: #{size} bytes exceeds #{MAX_SIZE} bytes; narrow include in mib-dump.config" if size > MAX_SIZE

    File.chmod(0644, out.path)
    File.rename(out.path, OUTPUT)
  end
end
