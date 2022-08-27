#!/usr/bin/env ruby
require 'fileutils'
require 'json'

Dir.chdir(__dir__)

Dir["./.github/workflows/*.jsonnet"].each do |src|
  dst = src.sub(/\.jsonnet$/, '.yml')
  p [src => dst]
  FileUtils.mkdir_p File.dirname(dst)

  File.open(dst, 'w') do |io|
    system('jsonnet', src, out: io, exception: true)
  end
end
