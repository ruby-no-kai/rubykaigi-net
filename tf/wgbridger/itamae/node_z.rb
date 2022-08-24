include_recipe './data'
node.reverse_merge!(
  wgbridger: {
    node: :z,
    local: node.fetch(:wgbridger).fetch(:nodes).fetch(:z),
    peer: node.fetch(:wgbridger).fetch(:nodes).fetch(:a),
  },
)

include_recipe './common'
include_recipe './bridge'
include_recipe './logging'

file '/etc/systemd/network/00-out.network' do
  content <<-EOF
[Match]
MACAddress=#{node.fetch(:wgbridger).fetch(:local).fetch(:out_mac)}

[Network]
Bridge=br0
  EOF
  owner 'root'
  group 'root'
  mode  '0644'
end

file "/etc/systemd/network/00-br0.network.d/disableaddressing.conf" do
  content <<-EOF
[Network]
IPv6AcceptRA=no
DHCP=no
LinkLocalAddressing=no
EOF
  owner 'root'
  group 'root'
  mode '0644'
end

include_recipe './connect_i'
include_recipe './nftables'
