#!/usr/bin/env ruby
require 'fileutils'
require 'json'

Dir.chdir(__dir__)
FileUtils.remove_entry_secure './gen/k8s'

Dir["./k8s/**/*.jsonnet"].each do |src|
  dst = src.sub(/\.jsonnet$/, '.yml').sub(/^\.\/k8s\//, './gen/k8s/')
  p [src => dst]
  FileUtils.mkdir_p File.dirname(dst)

  File.open(dst, 'w') do |io|
    system('jsonnet', src, out: io, exception: true)
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
  dst = src.sub(/^\.\/k8s\//, './gen/k8s')
  p [src => dst]
  FileUtils.mkdir_p File.dirname(dst)
  FileUtils.cp src, dst
end
