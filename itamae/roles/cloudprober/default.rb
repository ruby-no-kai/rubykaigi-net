include_role 'base'

package 'docker.io'

%w[
  /etc/systemd/network/00-management.network
].each do |_|
  template _ do
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'service[systemd-networkd]'
  end
end


file '/etc/sysctl.d/50-ping.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  content <<EOF
net.ipv4.ping_group_range=0 2147483647
EOF
  notifies :restart, 'service[systemd-sysctl]', :immediately
end

remote_file '/etc/cloudprober.cfg' do
  owner 'root'
  group 'root'
  mode '0644'
end

remote_file '/etc/systemd/system/cloudprober.service' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

service 'cloudprober' do
  action [:enable, :start]
end
