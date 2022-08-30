include_recipe './data'

package 'linux-modules-extra-raspi' # vxlan
package 'wireguard-tools'
package 'ldnsutils'
package 'bridge-utils'
package 'tcpdump'

file "/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg" do
  content "network: {config: disabled}\n"
  owner 'root'
  group 'root'
  mode  '0644'
  only_if 'test -e /etc/cloud/cloud.cfg.d'
end

file "/etc/systemd/network/00-wg0.netdev" do
  content <<EOF
[NetDev]
Name=wg0
Kind=wireguard

[WireGuard]
PrivateKey=#{node.fetch(:wgbridger).fetch(:local).fetch(:private)}
ListenPort=18782
EOF
  owner 'systemd-network'
  group 'systemd-network'
  mode '0600'
end

file "/etc/systemd/network/00-wg0.network" do
  me = node.fetch(:wgbridger).fetch(:local).fetch(:inner)
  content <<-EOF
[Match]
Name=wg0

[Network]
Address=#{me}/32

[Link]
MTUBytes=9000

#{
node.fetch(:wgbridger).fetch(:nodes).each_value.reject { |n| n[:inner] == me }.map { |n|
"[Route]
Gateway=0.0.0.0
Destination=#{n.fetch(:inner)}/32

"
}.join(?\n)}
  EOF

  owner 'root'
  group 'root'
  mode '0644'
end

directory "/etc/systemd/network/00-wg0.network.d" do
  owner 'root'
  group 'root'
  mode '0755'
end

directory "/etc/systemd/network/00-wg0.netdev.d" do
  owner 'root'
  group 'root'
  mode '0755'
end

directory '/etc/systemd/resolved.conf.d' do
  owner 'root'
  group 'root'
  mode  '0755'
end

file '/etc/systemd/resolved.conf.d/dns.conf' do
  content <<-EOF
[Resolve]
DNS=8.8.8.8#dns.google 8.8.4.4#dns.google 2001:4860:4860::8888#dns.google 2001:4860:4860::8844#dns.google
  EOF

  owner 'root'
  group 'root'
  mode  '0644'
end

