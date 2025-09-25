
# Generate NEC IX commnads to configure venue tunnels
#
# Interfaces:
# "Tunnel#{pop_num}.0" etherip-ipsec to pop (not in scope of this script)
# "Tunnel1#{peer_tun_num}0.0" etherip-ipsec to venue
# "Tunnel1#{peer_tun_num}1.0" etherip to venue

require 'ipaddr'

is_full = ARGV.delete('--full')

peer_address_chars = ('a'..'f').to_a + ('0'..'9').to_a
peer_addresses = ARGV.map.with_index { |arg,i| 
  a = IPAddr.new(arg)
  b = IPAddr.new(a.cidr)
  if a == b
    b | IPAddr.new("::dddd:#{peer_address_chars.fetch(i)*4}:0:1")
  else
    a
  end
}


SiteTun = Data.define(:num, :site, :nexthop, :interface)

SITE_TUNS = [
  SiteTun.new(1, 'hnd', 'fe80::208:e3ff:feff:fd90%GigaEthernet0.1', 'GigaEthernet0.1'),
  SiteTun.new(2, 'nrt', 'fe80::a%GigaEthernet0.0', 'GigaEthernet0.0'),
  SiteTun.new(3, 'itm', 'fe80::a%GigaEthernet0.0', 'GigaEthernet0.0'),
]


negates = []
SITE_TUNS.each do |site_tun|
  puts "!!!!!!!!! #{site_tun.site} !!!!!!!!!"
  negates << "!!!!!!!!! #{site_tun.site} !!!!!!!!!"

  peer_addresses.each do |peer_address|
    route = IPAddr.new(peer_address.cidr)
    puts          "ipv6 route #{route}/#{route.prefix} #{site_tun.nexthop}"
    negates << "no ipv6 route #{route}/#{route.prefix} #{site_tun.nexthop}"
  end
  puts
  peer_addresses.each_with_index do |peer_address, idx|
    num = (idx+1) * 10
    rendered = <<-EOF
*interface Tunnel#{num}.0
-  description Downstream: Tun#{site_tun.num}0.0@tun-0#{idx+1}.venue, Gi2.#{site_tun.num}0 [etherip-ipsec]
-  tunnel mode ether-ip ipsec-ikev2
-  no ip address
-  bridge-group #{num+1}
-  bridge ip tcp adjust-mss 1330
-  bridge ipv6 tcp adjust-mss 1330
-  ikev2 connect-type auto
-  ikev2 ipsec pre-fragment
-  ikev2 outgoing-interface #{site_tun.interface} #{site_tun.nexthop.sub(/%.+$/, '')}
-  ikev2 source-address ###TODO###
-  ikev2 ipsec-mode transport
-  ikev2 peer any authentication psk id fqdn tun-0#{idx+1}.venue.rubykaigi.net
*  no shutdown
*!
*interface Tunnel#{num+1}.0
-  description Downstream: Tun#{site_tun.num}1.0@tun-0#{idx+1}.venue, Gi2.#{site_tun.num}1 [etherip]
-  tunnel mode ether-ip ipv6
*  tunnel destination #{peer_address.to_s}
-  tunnel source ###TODO###
-  no ip address
-  bridge-group #{num+1}
-  bridge ip tcp adjust-mss 1330
-  bridge ipv6 tcp adjust-mss 1330
*  no shutdown
-!
    EOF

    if is_full
      puts rendered.gsub(/^./, '')
    else
      puts rendered.each_line.grep(/^\*/).join.gsub(/^./, '')
    end

    negates << "interface Tunnel#{num}.0"
    negates << "  shutdown"
    negates << "interface Tunnel#{num+1}.0"
    negates << "  shutdown"
  end

  puts
  puts
  negates << nil
  negates << nil
end

puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

puts negates.join("\n")
