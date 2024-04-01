require 'ipaddr'
require 'aws-sdk-ec2'
# Usage: ix_aws_tun.rb vpn-xxx

OUTGOING_IFACE = "GigaEthernet2:1.1"
IFACES = %w(Tunnel50.0 Tunnel51.0)
ASN = 65152
REMOTE_ASN = 64512

@ec2  = Aws::EC2::Client.new

vpn = @ec2.describe_vpn_connections(vpn_connection_ids: [ARGV.fetch(0)]).vpn_connections.fetch(0)

vpn.options.tunnel_options.zip(IFACES).each_with_index do |(tunnel,iface),idx|
  addr = IPAddr.new(tunnel.tunnel_inside_cidr)
  puts "ip route #{tunnel.outside_ip_address}/32 #{OUTGOING_IFACE}"
  puts "ikev2 authentication psk id ipv4 #{tunnel.outside_ip_address} key char #{tunnel.pre_shared_key}"
  puts "router bgp #{ASN}"
  puts "  neighbor #{addr.succ.to_s} remote-as #{REMOTE_ASN}"
  puts "  neighbor #{addr.succ.to_s} connect-interval 10"
  puts "  neighbor #{addr.succ.to_s} timers 6 30"
  puts "  neighbor #{addr.succ.to_s} description #{iface} #{vpn.vpn_connection_id}:#{idx}"
  puts "  neighbor #{addr.succ.to_s} advertisement-interval 6"
  puts "  address-family ipv4 unicast"
  puts "    neighbor #{addr.succ.to_s} route-map aws-lo-in in"
  puts "    neighbor #{addr.succ.to_s} route-map aws-lo-out out"
  puts "  exit"
  puts "exit"
  puts "interface #{iface}"
  puts "  description Core: #{vpn.vpn_connection_id}:#{idx} [ipsec]"
  puts "  ip address #{addr.succ.succ.to_s}/30"
  puts "  tunnel mode ipsec-ikev2"
  puts "  ip mtu 1390"
  puts "  ip tcp adjust-mss 1342"
  puts "  ikev2 connect-type auto"
  puts "  ikev2 profile aws"
  puts "  ikev2 ipsec pre-fragment"
  puts "  ikev2 outgoing-interface #{OUTGOING_IFACE} auto"
  puts "  ikev2 source-address #{OUTGOING_IFACE}"
  puts "  ikev2 peer #{tunnel.outside_ip_address} authentication psk id ipv4 #{tunnel.outside_ip_address}"
  puts "  no shutdown"
  puts "exit"
  puts
end
