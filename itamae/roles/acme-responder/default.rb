node.reverse_merge!(
  bird: {
    router_id: node[:ec2][:'local-ipv4'],
  },
  acme_responder: {
    underlay: {
      address6: node[:ec2][:ipv6],
    },
    overlay: {
      address4: %w[192.50.220.164/31],
      address6: %w[2001:df0:8500:ca6d:53::c/127],
    },
  },
)

include_role 'base'
include_cookbook 'bird'
include_cookbook 'nftables'
include_cookbook 'nginx'

template '/etc/iproute2/rt_tables.d/overlay.conf' do
  owner 'root'
  group 'root'
  mode '0644'
end

template '/etc/nftables/acme-responder.conf' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :reload, 'service[nftables]'
end

template '/etc/nginx/sites-available/default' do
  owner 'root'
  group 'root'
  mode '0644'
  notifies :run, 'execute[nginx -s reload]'
end

%w[
  50-lo.network
  50-ip6tnl-rola.netdev
  50-ip6tnl-rola.network
  50-ip6tnl-mahiru.netdev
  50-ip6tnl-mahiru.network
].each do |fname|
  template "/etc/systemd/network/#{fname}" do
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'service[systemd-networkd]'
  end
end

template '/etc/bird/bird.conf.d/acme-responder.conf' do
  owner 'root'
  group 'bird'
  mode '0644'
  notifies :reload, 'service[bird]'
end
