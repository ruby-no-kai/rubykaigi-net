file "/etc/systemd/network/00-br0.netdev" do
  content <<-EOF
[NetDev]
Name=br0
Kind=bridge

[Bridge]

  EOF
  owner 'root'
  group 'root'
  mode '0644'
end


file "/etc/systemd/network/00-br0.network" do
  content <<-EOF
[Match]
Name=br0

[Network]
EOF
  owner 'root'
  group 'root'
  mode '0644'
end

directory "/etc/systemd/network/00-br0.network.d" do
  owner 'root'
  group 'root'
  mode '0755'
end

file "/etc/systemd/network/00-vxlan0.netdev" do
  content <<-EOF
[NetDev]
Name=vxlan0
Kind=vxlan

[VXLAN]
Remote=#{node.fetch(:wgbridger).fetch(:peer).fetch(:inner)}
Independent=yes
VNI=18782

EOF
  owner 'root'
  group 'root'
  mode '0644'
end

file "/etc/systemd/network/00-vxlan0.network" do
  content <<-EOF
[Match]
Name=vxlan0

[Network]
Bridge=br0
EOF
  owner 'root'
  group 'root'
  mode '0644'
end

directory "/etc/systemd/network/00-vxlan0.network.d" do
  owner 'root'
  group 'root'
  mode '0755'
end
