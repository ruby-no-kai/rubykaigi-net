node.reverse_merge!(
  systemd_networkd: {
    migrate_netplan: false,
  },
  wire: {
    interfaces: {
      loopback: {
        address4: %w[10.33.0.42],
        address6: %w[2001:df0:8500:ca00::42],
      },
      management: {
        name: 'me0',
        path: '*14.0-usb-0:*:1.0',
        duid: '00:00:ba:2c:33:00:42',
      },
      underlay: {
        name: 'enp3s0',
        ipv6_token: 'static:::8888:bbbb:0:1',
      },
      downstream: {
        name: 'enp2s0',
        local_as: 65088,
        peer_as: 65030,
        link4: {
          local: '10.33.22.47',
          peer: '10.33.22.46',
        },
        link6: {
          local: '2001:df0:8500:ca22:46::b',
          peer: '2001:df0:8500:ca22:46::a',
        },
      },
    },
    tunnels: {
      wg_wire03: {
        listen_port: 8703,
        peer_endpoint: 'rknet-wire-03.i.open.ad.jp:8702',
        peer_public_key: 'lJuF/78NB3DJpFIErUopDfgiBDopSC5OrHN8xYCCbRg=',
        local_as: 65088,
        peer_as: 65088,
        link4: {
          local: '10.33.22.94',
          peer: '10.33.22.95',
        },
        link6: {
          local: '2001:df0:8500:ca22:94::a',
          peer: '2001:df0:8500:ca22:94::b',
        },
      },
      wg_wire99: {
        listen_port: 8799,
        peer_endpoint: 'ep.wire.rubykaigi.net:8702',
        peer_public_key: 'txcw4lC+WltZeGd6lmCm6vIN8uXtKZHCi3pPuxJ+8x4=',
        local_as: 65088,
        peer_as: 65088,
        link4: {
          local: '10.33.22.157',
          peer: '10.33.22.156',
        },
        link6: {
          local: '2001:df0:8500:ca22:156::b',
          peer: '2001:df0:8500:ca22:156::a',
        },
      },
    },
  },
)

include_role 'wire'
include_cookbook 'bluetooth-getty'
