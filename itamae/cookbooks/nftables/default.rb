package 'nftables'

execute '/etc/nftables.conf' do
  action :nothing
end

directory '/etc/nftables' do
  owner 'root'
  group 'root'
  mode '0755'
end

remote_file '/etc/nftables.conf' do
  owner 'root'
  group 'root'
  mode '0755'
  notifies :reload, 'service[nftables]'
end

service 'nftables' do
  action [:enable, :start]
end

