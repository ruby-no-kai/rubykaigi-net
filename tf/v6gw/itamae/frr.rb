package 'frr'

file '/etc/frr/daemons' do
  action :edit
  block do |content|
    content.sub!(/^bgpd=.*$/, 'bgpd=yes')
    content.sub!(/^bfdd=.*$/, 'bfdd=yes')
  end
  notifies :restart, 'service[frr]', :immediately
end

template '/etc/frr/frr.conf' do
  owner 'frr'
  group 'frr'
  mode '0640'
  notifies :reload, 'service[frr]', :immediately
end

service 'frr' do
  action [:enable, :start]
end
