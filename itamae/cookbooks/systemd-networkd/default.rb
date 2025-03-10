node.reverse_merge!(
  systemd_networkd: {
    migrate_netplan: !node[:hocho_ec2],
    manage_foreign_routes: true,
  },
)

service 'networking' do
  action [:disable]
end

package 'ifupdown' do
  action :remove
end

file '/etc/cloud/cloud.cfg.d/99-disable-network-config.cfg' do
  content "network: {config: disabled}\n"
  owner 'root'
  group 'root'
  mode  '0644'
  only_if 'test -e /etc/cloud/cloud.cfg.d'
end

if node[:systemd_networkd][:migrate_netplan]
  execute 'mkdir -p /etc/systemd/network && cp -pv -t /etc/systemd/network /run/systemd/network/*netplan*' do
    only_if "test -e /etc/netplan && test -d /run/systemd/network"
  end
end

execute "rm -rf /etc/netplan && netplan generate" do
  only_if "test -e /etc/netplan"
  notifies :restart, 'service[systemd-networkd]'
end

directory '/etc/systemd/networkd.conf.d' do
  owner 'root'
  group 'root'
  mode '0755'
end

if node[:systemd_networkd][:manage_foreign_routes]
  file '/etc/systemd/networkd.conf.d/99-manage-foreign-routes.conf' do
    action :delete
  end
else
  file '/etc/systemd/networkd.conf.d/99-manage-foreign-routes.conf' do
    content "[Network]\nManageForeignRoutes=no\n"
    owner 'root'
    group 'root'
    mode '0644'
  end
end

package 'systemd-resolved' do
  action :install
end

service 'systemd-networkd' do
  action [:enable, :start]
end

execute 'networkctl reload' do
  action :nothing
end

directory '/etc/systemd/resolved.conf.d' do
  owner 'root'
  group 'root'
  mode '755'
end

template '/etc/systemd/resolved.conf.d/60-local.conf' do
  owner 'root'
  group 'root'
  mode '644'
  notifies :restart, 'service[systemd-resolved]'
end

service 'systemd-resolved' do
  action [:enable, :start]
end

link '/etc/resolv.conf' do
  to '/run/systemd/resolve/resolv.conf'
  force true
end
