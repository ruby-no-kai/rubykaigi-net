#!/usr/bin/env ruby
require 'pathname'

Dir.chdir Pathname(__dir__).join('../itamae/cookbooks/xlat/files/opt/xlat') do
  system('bundle lock --update', exception: true)
end
