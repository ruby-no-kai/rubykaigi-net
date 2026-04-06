ec2 = !!(node[:ec2][:'instance-type'] rescue nil)

node.reverse_merge!(
  dns: {
    servers: ec2 ? [] : %w[192.50.220.164 192.50.220.165],
    search_domains: %w[f.rubykaigi.net],
  },
)

include_cookbook 'systemd-networkd'
include_cookbook 'iproute2'
include_cookbook 'prometheus-node-exporter'
