node.fetch(:wire).fetch(:tunnels).each do |name, attr|
  template "/var/lib/machines/overlay/etc/systemd/network/10-#{name}.netdev" do
    source 'templates/var/lib/machines/overlay/etc/systemd/network/10-wireguard.netdev'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      name: name,
      attr: attr,
    )
  end

  template "/etc/systemd/network/10-#{name}.network" do
    source 'templates/etc/systemd/network/10-wireguard.network'
    owner 'root'
    group 'root'
    mode '0644'
    variables(
      name: name,
      attr: attr,
    )
    notifies :run, 'execute[networkctl reload]'
  end
end

template '/usr/bin/rk-move-overlay-wg-iface' do
  owner 'root'
  group 'root'
  mode  '0755'
end

template '/etc/systemd/system/rk-move-overlay-wg-iface.service' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

service 'rk-move-overlay-wg-iface.service' do
  action [:enable]
end
