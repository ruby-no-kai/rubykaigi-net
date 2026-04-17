node.reverse_merge!(
  systemd_networkd: {
    migrate_netplan: false,
  },
  wire: {
    interfaces: {
      loopback: {
        address4: %w[10.33.0.44],
        address6: %w[2001:df0:8500:ca00::44],
      },
      management: {
        name: 'me0',
        path: '*14.0-usb-0:*:1.0',
        duid: '00:00:ba:2c:33:00:44',
      },
      underlay: {
        name: 'enp3s0',
        ipv6_token: 'static:::8888:dddd:0:1',
        dhcpv4: true,
      },
      downstream: {
        name: 'enp2s0',
        local_as: 65088,
        peer_as: 65032,
        link4: {
          local: '10.33.22.198',
          peer: '10.33.22.199',
        },
        link6: {
          local: '2001:df0:8500:ca22:198::a',
          peer: '2001:df0:8500:ca22:198::b',
        },
      },
    },
    tunnels: {
      wg_wire01: {
        listen_port: 8701,
        peer_endpoint: 'rknet-wire-01.i.open.ad.jp:8704',
        peer_public_key: 'gmhfxZ++XH+F+zMjSjqa3aaTb82vF0A5HyfmSa++Bnk=',
        local_as: 65088,
        peer_as: 65088,
        link4: {
          local: '10.33.22.93',
          peer: '10.33.22.92',
        },
        link6: {
          local: '2001:df0:8500:ca22:92::b',
          peer: '2001:df0:8500:ca22:92::a',
        },
      },
      wg_wire02: {
        listen_port: 8702,
        peer_endpoint: 'rknet-wire-02.i.open.ad.jp:8704',
        peer_public_key: '+/YjEC81NSFm6AEghidEaTOaz0tNyMwlncFxrSE4NxQ=',
        local_as: 65088,
        peer_as: 65088,
        link4: {
          local: '10.33.22.97',
          peer: '10.33.22.96',
        },
        link6: {
          local: '2001:df0:8500:ca22:96::b',
          peer: '2001:df0:8500:ca22:96::a',
        },
      },
      wg_wire99: {
        listen_port: 8799,
        peer_endpoint: 'ep.wire.rubykaigi.net:8704',
        peer_public_key: 'txcw4lC+WltZeGd6lmCm6vIN8uXtKZHCi3pPuxJ+8x4=',
        local_as: 65088,
        peer_as: 65088,
        link4: {
          local: '10.33.22.155',
          peer: '10.33.22.154',
        },
        link6: {
          local: '2001:df0:8500:ca22:154::b',
          peer: '2001:df0:8500:ca22:154::a',
        },
      },
    },
  },
)

include_role 'wire'
include_cookbook 'bluetooth-getty'
