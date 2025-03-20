package 'bird2'

service 'bird' do
  action [:enable, :start]
end

directory '/etc/bird' do
  owner 'root'
  group 'bird'
  mode '0755'
end

directory '/etc/bird/bird.conf.d' do
  owner 'root'
  group 'bird'
  mode '0755'
end

template '/etc/bird/bird.conf' do
  owner 'root'
  group 'bird'
  mode '0644'
  notifies :reload, 'service[bird]'
end
