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

include_cookbook 'cpufreq'
include_cookbook 'nftables'
include_cookbook 'xtables'
include_cookbook 'xlat'
include_cookbook 'bird'
include_cookbook 'conntrack-exporter'

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

if node.dig(:plat, :interfaces, :management)
  %w[
    00-management.network
    00-management.link
  ].each do |fname|
    template "/etc/systemd/network/#{fname}" do
      owner 'root'
      group 'root'
      mode '0644'
      notifies :restart, 'service[systemd-networkd]'
    end
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
  mode '0644'
  notifies :reload, 'service[bird]'
end

template '/etc/modules-load.d/nf-conntrack.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[systemd-modules-load]'
end

template '/etc/sysctl.d/90-nf-conntrack.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :restart, 'service[systemd-sysctl]'
end
