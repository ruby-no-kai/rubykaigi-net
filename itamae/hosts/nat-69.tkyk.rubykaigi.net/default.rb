node.reverse_merge!(
  plat: {
    nat64: {
      outer_public: '192.50.220.166/32',
      outer_private: '10.33.40.64/29',
    },
    interfaces: {
      loopback: {
        address4: %w[10.33.0.206],
        address6: %w[2001:df0:8500:ca00::206],
      },
      management: {
        name: 'me0',
        path: 'pci-0000:06:00.0',
        duid: '00:00:ba:2c:33:09:29',
      },
      outside: {
        name: 'enp1s0',
        local_as: 65096,
        peer_as: 65090,
        link4: {
          local: '10.33.22.221',
          peer: '10.33.22.220',
        },
        link6: {
          local: '2001:df0:8500:ca22:220::b',
          peer: '2001:df0:8500:ca22:220::a',
        },
      },
      inside: {
        name: 'enp2s0',
        local_as: 65096,
        peer_as: 65091,
        link4: {
          local: '10.33.22.222',
          peer: '10.33.22.223',
        },
        link6: {
          local: '2001:df0:8500:ca22:222::a',
          peer: '2001:df0:8500:ca22:222::b',
        },
      },
    },
  }
)

include_role 'plat'
