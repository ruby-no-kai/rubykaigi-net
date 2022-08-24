include_recipe './data'
node.reverse_merge!(
  wgbridger: {
    node: :i,
    local: node.fetch(:wgbridger).fetch(:nodes).fetch(:i),
  },
)

include_recipe './common'

file "/etc/systemd/network/00-wg0.network.d/forwarding.conf" do
  content <<-EOF
[Network]
IPForward=yes
EOF

  owner 'root'
  group 'root'
  mode  '0644'
end

file "/etc/sysctl.d/99-icmp-redirect.conf" do
  content <<-EOF
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
EOF
  owner 'root'
  group 'root'
  mode  '0644'
end

file "/etc/systemd/network/00-wg0.netdev.d/nodes.conf" do
  content <<-EOF
[WireGuardPeer]
PublicKey=#{node.fetch(:wgbridger).fetch(:nodes).fetch(:a).fetch(:public)}
AllowedIPs=#{node.fetch(:wgbridger).fetch(:nodes).fetch(:a).fetch(:inner)}/32

[WireGuardPeer]
PublicKey=#{node.fetch(:wgbridger).fetch(:nodes).fetch(:z).fetch(:public)}
AllowedIPs=#{node.fetch(:wgbridger).fetch(:nodes).fetch(:z).fetch(:inner)}/32
  EOF

  owner 'root'
  group 'root'
  mode  '0644'
end

