include_recipe './data'
node.reverse_merge!(
  wgbridger: {
    node: :a,
    local: node.fetch(:wgbridger).fetch(:nodes).fetch(:a),
    peer: node.fetch(:wgbridger).fetch(:nodes).fetch(:z),
  },
)

include_recipe './common'
include_recipe './bridge'
include_recipe './logging'

execute 'rm -rf /etc/netplan' do
  only_if 'test -e /etc/netplan'
end

file '/etc/systemd/network/00-eth0.network' do
  content <<-EOF
[Match]
Name=eth0

[Network]
Bridge=br0
  EOF
  owner 'root'
  group 'root'
  mode  '0644'
end

file '/etc/systemd/network/00-br0.network.d/ngn.network' do
  content <<-EOF
[Network]
IPv6AcceptRA=yes
LinkLocalAddressing=yes
DNS=2001:4860:4860::8888
DNS=2001:4860:4860::8844
  EOF
  owner 'root'
  group 'root'
  mode  '0644'
end

include_recipe './connect_i'
include_recipe './nftables'
