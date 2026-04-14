node.reverse_merge!(
  systemd_networkd: {
    manage_foreign_routes: false,
  },
  wire: {
  },
  bird: {
    router_id: [*node.dig(:wire, :interfaces, :loopback).fetch(:address4)].first,
  },
)

include_role 'base'
include_cookbook 'ruby'

include_cookbook 'cpufreq'
include_cookbook 'nftables'

package 'wireguard-tools'


%w[
  00-lo.network
].each do |fname|
  template "/etc/systemd/network/#{fname}" do
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'service[systemd-networkd]'
  end
end

if node.dig(:wire, :interfaces, :management)
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

file "/etc/wire.json" do
  content "#{JSON.pretty_generate(node[:wire])}\n"
  owner 'root'
  group 'root'
  mode '0644'
end

include_recipe './key.rb'
include_recipe './overlay.rb'
include_recipe './wireguard.rb'

service 'systemd-nspawn@overlay.service' do
  action [:enable, :start]
end



template '/etc/nftables/wire.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :reload, 'service[nftables]'
end

# template '/etc/bird/bird.conf.d/plat.conf' do
#   owner 'root'
#   group 'bird'
#   mode '0644'
#   notifies :reload, 'service[bird]'
# end
