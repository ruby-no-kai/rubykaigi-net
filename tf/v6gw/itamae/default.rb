node[:ec2] = JSON.parse(File.read('/run/cloud-init/instance-data.json')).dig('ds', 'meta-data')

template '/etc/iproute2/rt_tables.d/v6gw.conf' do
  owner 'root'
  group 'root'
  mode '0644'
end

include_recipe './systemd-networkd.rb'
include_recipe './frr.rb'
