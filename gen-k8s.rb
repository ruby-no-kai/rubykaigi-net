#!/usr/bin/env ruby
require 'fileutils'
require 'json'
require 'tmpdir'


jsonnet = system('jrsonnet', '--help', out: File::NULL, err: [:child, :out]) ? 'jrsonnet' : 'jsonnet'

Dir.chdir(__dir__)
tmpdir = Dir.mktmpdir

Dir["./k8s/**/*.jsonnet"].each do |src|
  dst = File.join(tmpdir, src.sub(/\.jsonnet$/, '.yml'))
  p [src => dst]
  FileUtils.mkdir_p File.dirname(dst)

  File.open(dst, 'w') do |io|
    system(jsonnet, src, out: io, exception: true)
  end

  out = JSON.parse(File.read(dst))
  if out.is_a?(Array)
    File.open(dst, 'w') do |io|
      out.each do |doc|
        io.puts JSON.pretty_generate(doc)
        io.puts "---"
      end
    end
  end
end

Dir["./k8s/**/*.yml"].each do |src|
  dst = File.join(tmpdir, src.sub(/^\.\/k8s\//, './gen/k8s'))
  p [src => dst]
  FileUtils.mkdir_p File.dirname(dst)
  FileUtils.cp src, dst
end

system('rsync', '-av','--delete', File.join(tmpdir, 'k8s/'), './gen/k8s')
