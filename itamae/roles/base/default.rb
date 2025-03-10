node.reverse_merge!(
  dns: {
    servers: %w[192.50.220.164 192.50.220.165],
    search_domains: %w[f.rubykaigi.net],
  },
)

include_cookbook 'systemd-networkd'
