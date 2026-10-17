%w[iproute2 iw].each do |name|
  package name
end

remote_file '/usr/local/sbin/rk-wifi-netns' do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/systemd/system/rk-wifi-netns.service' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[systemctl daemon-reload]', :immediately
end

service 'rk-wifi-netns' do
  action :enable
end
