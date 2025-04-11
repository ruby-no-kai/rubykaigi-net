node.reverse_merge!(
  systemd_networkd: {
    migrate_netplan: false,
  },
  plat: {
    nat64: {
      outer_public: '192.50.220.163/32',
      outer_private: '10.33.40.163/32',
    },
    interfaces: {
      loopback: {
        address4: %w[10.33.0.24],
        address6: %w[2001:df0:8500:ca00::24],
      },
      management: {
        name: 'me0',
        path: '*14.0-usb-0:*:1.0',
        duid: '00:00:ba:2c:33:00:24',
      },
      outside: {
        name: 'enp1s0',
        local_as: 65026,
        peer_as: 65010,
        link4: {
          peer: '10.33.22.50',
          local: '10.33.22.51',
        },
        link6: {
          peer: '2001:df0:8500:ca22:50::a',
          local: '2001:df0:8500:ca22:50::b',
        },
      },
      inside: {
        name: 'enp2s0',
        local_as: 65026,
        peer_as: 65030,
        link4: {
          local: '10.33.22.66',
          peer: '10.33.22.67',
        },
        link6: {
          local: '2001:df0:8500:ca22:66::a',
          peer: '2001:df0:8500:ca22:66::b',
        },
      },
    },
  }
)

include_role 'plat'
