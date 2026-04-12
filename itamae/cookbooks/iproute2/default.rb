directory '/etc/iproute2' do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/iproute2/rt_tables' do
  owner 'root'
  group 'root'
  mode  '0644'
end
