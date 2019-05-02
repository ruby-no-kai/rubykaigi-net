eni = node.fetch(:hocho_ec2).fetch(:network_interfaces).find { |_| _[:subnet_id] == 'subnet-03a535b04955c40c7' }
node.reverse_merge!(
  bird: {
    id: eni.fetch(:private_ip_addresses).fetch(0).fetch(:private_ip_address),
  },
  vpn_router: {
    primary_ip: eni.fetch(:private_ip_addresses).fetch(0).fetch(:private_ip_address),
    primary_ip6: eni.fetch(:ipv_6_addresses)[0]&.fetch(:ipv_6_address),
    iface: {
      world: 'ens6',
      core: 'ens5',
      mgmt: 'ens5',
    },
    stubnet: node.fetch(:hocho_vpc).fetch(:cidr_block_association_set).map do |v4|
      v4.fetch(:cidr_block)
    end,
    vpn_rtb4: {
      default: false,
      static: [
        *(node.fetch(:hocho_vpc).fetch(:cidr_block_association_set).map do |v4|
          "route #{v4.fetch(:cidr_block)} via #{node.fetch(:self_router)};"
        end),
        "route #{node[:site_cidr]} unreachable;",
      ],
    },
    vpns: {
      venue1: {
        leftsubnet: '0.0.0.0/0',
        rightsubnet: '0.0.0.0/0',
        leftid: "@vpn-001.aws.nw.rubykaigi.org",
        rightid: '@gw-01.venue.nw.rubykaigi.org',
        left: eni.fetch(:ipv_6_addresses)[0]&.fetch(:ipv_6_address),
        right: '%any',
        ifname: 'venue1',
        inner_left: '10.33.22.1/30',
        inner_right: '10.33.22.2/30',
        mark: 20,
        rtb: 'vpn',
        ikelifetime: '21600s',
        keylife: '3600s',
        rekeymargin: '600s',
        aggressive: true,
        ike: 'aes256-sha512-modp2048',
        esp: 'aes256-sha256-modp2048',
        psk: node[:secrets][:vpn_psk].chomp,
      },
      venue2: {
        leftsubnet: '0.0.0.0/0',
        rightsubnet: '0.0.0.0/0',
        leftid: "@vpn-001.aws.nw.rubykaigi.org",
        rightid: '@gw-02.venue.nw.rubykaigi.org',
        left: eni.fetch(:ipv_6_addresses)[0]&.fetch(:ipv_6_address),
        right: '%any',
        ifname: 'venue2',
        inner_left: '10.33.22.5/30',
        inner_right: '10.33.22.6/30',
        mark: 21,
        rtb: 'vpn',
        ikelifetime: '21600s',
        keylife: '3600s',
        rekeymargin: '600s',
        aggressive: true,
        ike: 'aes256-sha512-modp2048',
        esp: 'aes256-sha256-modp2048',
        psk: node[:secrets][:vpn_psk].chomp,
      },

    },
  },
)

file "/etc/systemd/network/99-ens6.network" do
  content <<-EOF
[Match]
Name=ens6
[Network]
DHCP=both
IPForward=yes
IPv6AcceptRA=yes
[DHCP]
UseMTU=yes
UseDNS=yes
UseDomains=yes
RouteMetric=100
  EOF
  owner 'root'
  group 'root'
  mode  '0644'
end

file "/etc/systemd/network/ethernet.network" do
  content <<-EOF
[Match]
Name=en*
[Network]
DHCP=both
IPForward=yes
IPv6AcceptRA=yes
[DHCP]
UseMTU=yes
UseDNS=yes
UseDomains=yes
  EOF
  owner 'root'
  group 'root'
  mode  '0644'
end
