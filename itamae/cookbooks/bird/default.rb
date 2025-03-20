package 'bird2'
package 'prometheus-bird-exporter'

file '/etc/default/prometheus-bird-exporter' do
  content "ARGS=-bird.v2 -format.new=true\n"
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[prometheus-bird-exporter.service]'
end

service 'bird' do
  action [:enable, :start]
end

service 'prometheus-bird-exporter.service' do
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
