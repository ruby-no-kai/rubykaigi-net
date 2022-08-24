file "/etc/systemd/network/00-wg0.netdev.d/node-i.conf" do
  me = node.fetch(:wgbridger).fetch(:local).fetch(:inner)
  content <<-EOF
[WireGuardPeer]
PublicKey=#{node.fetch(:wgbridger).fetch(:i).fetch(:public)}
Endpoint=#{node.fetch(:wgbridger).fetch(:i).fetch(:endpoint)}:18782
AllowedIPs=#{node.fetch(:wgbridger).fetch(:nodes).each_value.reject { |n| n[:inner] == me }.map { |n| "#{n[:inner]}/32" }.compact.join(?,)}
PersistentKeepalive=5

  EOF

  owner 'root'
  group 'root'
  mode  '0644'
end
