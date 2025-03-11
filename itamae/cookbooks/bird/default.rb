package 'bird2'

service 'bird' do
  action [:enable, :start]
end

directory '/etc/bird/bird.conf.d' do
  owner 'root'
  group 'bird'
  mode '0750'
end

template '/etc/bird/bird.conf' do
  owner 'root'
  group 'bird'
  mode '0640'
  notifies :reload, 'service[bird]'
end
