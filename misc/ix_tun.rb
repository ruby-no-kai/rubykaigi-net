require 'ipaddr'
# Usage: ix_tun.rb hnd br-01

IFACES = %w(bvi0 bvi10 bvi1 bvi11 tun100 tun110 tun101 tun111)

ASNS = {
  hnd: 65001,
  itm: 65002,
  venue: 65010,
}

host_lines = File.read(File.join(__dir__, '..', 'hosts.txt'))

HostInfo = Struct.new(:dc, :network, :cidr, :ip, :name, :iface, :mac, :primary)
hosts = host_lines.lines.
  map { |l| HostInfo.new(*l.chomp.split(?\t, 7).map(&:strip), false) }.
  reject { |_| _.ip.nil? || _.ip.empty? }.
  group_by { |_| [_.dc, _.name, _.ip.include?(?:)] }.
  map { |k, ips| ips[0].primary = true; [k, ips] }.
  to_h


target = ARGV[0,2]

BgpPeer = Struct.new(:ip, :asn, :desc, :mapin, :mapout, :default, keyword_init: true)
bgp_peers = []
ospf3_ifaces = []
IFACES.each do |iface|
  v4 = (hosts[[*target, false]] || []).find { |is| is.iface == iface }
  v6 = (hosts[[*target, true]] || []).find { |is| is.iface == iface }
  canonical = iface.sub(/bvi/,'BVI').sub(/tun(\d+)/, 'Tunnel\1.0')
  puts "interface #{canonical}"
  puts "  ip address #{v4.ip}/30"
  puts "  ipv6 enable"
  puts "  ipv6 address #{v6.ip}/124"
  puts "  ipv6 ospf cost #{iface.start_with?('tun') ? 400 : 200}"
  puts "  ipv6 ospf hello-interval 6"
  puts "  ipv6 ospf dead-interval 30"
  puts "!"

  ospf3_ifaces << [canonical, v6] if v6

  bgppeer = BgpPeer.new
  v4a = IPAddr.new("#{v4.ip}/30")
  v4as = v4a.to_range.to_a
  bgppeer.ip = v4as.index{ |_| _.to_s == v4.ip } == 1 ? v4as[2] : v4as[1]
  peerinfo = hosts.each_value.to_a.flatten.find { |_| _.ip == bgppeer.ip.to_s }
  bgppeer.asn = ASNS.fetch(peerinfo.dc.to_sym)
  bgppeer.desc = canonical
  bgppeer.mapin = iface.start_with?('tun') ? 'private-in' : 'public-in'
  bgppeer.mapout = iface.start_with?('tun') ? 'private-out' : 'public-out'
  bgppeer.default = iface.start_with?('bvi')

  bgp_peers << bgppeer
end

puts "ipv6 router ospf 1"
ospf3_ifaces.each do |(canonical, _)|
  puts "  network #{canonical} area 0"
end
puts "!"


puts "router bgp #{ASNS[ARGV[0].to_sym]}"
bgp_peers.each do |peer|
  puts "  neighbor #{peer.ip} remote-as #{peer.asn}"
  puts "  neighbor #{peer.ip} description #{peer.desc}"
  puts "  neighbor #{peer.ip} connect-interval 10"
  puts "  neighbor #{peer.ip} advertisement-interval 6"
  puts "  neighbor #{peer.ip} timers 6 30"
end
puts "  address-family ipv4 unicast"
bgp_peers.each do |peer|
  puts "    neighbor #{peer.ip} route-map #{peer.mapin} in"
  puts "    neighbor #{peer.ip} route-map #{peer.mapout} out"
  puts "    no neighbor #{peer.ip} send-default "unless peer.default
end
