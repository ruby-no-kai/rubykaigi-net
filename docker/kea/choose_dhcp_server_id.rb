#!/usr/bin/env ruby
require 'ipaddr'

dev = IO.popen(%w(ip -o route get 8.8.8.8), 'r', &:read).match(/dev ([^ ]+)/)[1].chomp
addr = IO.popen([*%w(ip -o address show dev), dev], 'r', &:read).match(/inet ([^ ]+)/)[1].chomp
net = IPAddr.new(addr)

candidates = ENV.fetch('DHCP_SERVER_IDS', '').split(',')

candidates.each do |candidate|
  if net.include?(IPAddr.new(candidate))
    puts candidate
    exit
  end
end

puts addr.split(?/)[0]
