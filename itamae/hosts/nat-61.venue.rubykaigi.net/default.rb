node.reverse_merge!(
  systemd_networkd: {
    migrate_netplan: false,
  },
  plat: {
    nat64: {
      outer_public: '192.50.220.162',
      outer_private: '10.33.40.162',
    },
    interfaces: {
      loopback: {
        address4: %w[10.33.0.23],
        address6: %w[2001:df0:8500:ca00::23],
      },
      management: {
        name: 'me0',
        path: '*14.0-usb-0:*:1.0',
        duid: '00:00:ba:2c:33:00:23',
      },
      outside: {
        name: 'enp1s0',
        local_as: 65026,
        peer_as: 65010,
        link4: {
          peer: '10.33.22.48',
          local: '10.33.22.49',
        },
        link6: {
          peer: '2001:df0:8500:ca22:48::a',
          local: '2001:df0:8500:ca22:48::b',
        },
      },
      inside: {
        name: 'enp2s0',
        local_as: 65026,
        peer_as: 65030,
        link4: {
          local: '10.33.22.64',
          peer: '10.33.22.65',
        },
        link6: {
          local: '2001:df0:8500:ca22:64::a',
          peer: '2001:df0:8500:ca22:64::b',
        },
      },
    },
  }
)

include_role 'plat'
