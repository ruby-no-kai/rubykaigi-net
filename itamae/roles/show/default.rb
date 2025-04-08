node.reverse_merge!(
  systemd_networkd: {
    manage_foreign_routes: false,
  },
  show: {
  },
  bird: {
    #router_id: 
  },
)
include_role 'base'

include_cookbook 'ruby'
include_cookbook 'nftables'
include_cookbook 'bird'

file '/etc/rk-show.json' do
  content "#{JSON.pretty_generate(node.fetch(:show))}\n"
  owner 'root'
  group 'root'
  mode  '0644'
end

template '/usr/local/bin/rk-ensure-veth' do
  owner 'root'
  group 'root'
  mode  '0755'
end
template '/etc/systemd/system/rk-ensure-veth.service' do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end
service 'rk-ensure-veth.service' do
  action [:enable, :start]
end

template '/etc/systemd/network/00-management.network' do
  owner 'root'
  group 'root'
  mode  '0644'
end


node.dig(:show, :interfaces, :servers).each_with_index do |server, i|
  template "/etc/systemd/network/00-server#{i}.network" do
    variables(iface: server)
    source 'templates/etc/systemd/network/00-server.network'
    owner 'root'
    group 'root'
    mode  '0644'
  end
end

template "/etc/systemd/network/00-client.network" do
  variables(iface: node.dig(:show, :interfaces, :client))
  owner 'root'
  group 'root'
  mode  '0644'
end

template '/etc/nftables/show.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :reload, 'service[nftables]'
end

template "/etc/bird/bird.conf.d/show.conf" do
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :reload, 'service[bird]'
end
