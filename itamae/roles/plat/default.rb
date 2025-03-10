node.reverse_merge!(
  systemd_networkd: {
    manage_foreign_routes: false,
  },
  plat: {
  },
  bird: {
    router_id: [*node.dig(:plat, :interfaces, :loopback).fetch(:address4)].first,
  },
)

include_role 'base'

include_cookbook 'nftables'
include_cookbook 'xlat'
include_cookbook 'bird'

package 'conntrack'

%w[
  00-lo.network
  00-inside.network
  00-outside.network
  00-tun-siit.network
].each do |fname|
  template "/etc/systemd/network/#{fname}" do
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'service[systemd-networkd]'
  end
end

template '/etc/nftables/plat.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :reload, 'service[nftables]'
end

template '/etc/bird/bird.conf.d/plat.conf' do
  owner 'root'
  group 'bird'
  mode '0640'
  notifies :reload, 'service[bird]'
end
