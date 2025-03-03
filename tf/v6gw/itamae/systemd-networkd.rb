package 'linux-modules-extra-aws'

%w[
  tun-hnd.netdev tun-nrt.netdev tun.network
  vxlan-66.netdev vxlan-66.network
  br-66.netdev br-66.network
  vrf-v6gw.netdev vrf-v6gw.network
].each do |_|
  template "/etc/systemd/network/#{_}" do
    owner 'root'
    group 'root'
    mode '0644'
    notifies :run, 'execute[networkctl reload]'
  end
end

directory '/etc/systemd/network/10-netplan-ens5.network.d' do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/systemd/network/10-netplan-ens5.network.d/ens5.override.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[networkctl reload]'
  notifies :run, 'execute[networkctl reconfigure ens5]'
end

execute 'networkctl reload' do
  action :nothing
end

execute 'networkctl reconfigure ens5' do
  action :nothing
end
