node.reverse_merge!(
  systemd_networkd: {
    migrate_netplan: false,
  },
  wire: {
    interfaces: {
      loopback: {
        address4: %w[10.33.0.41],
        address6: %w[2001:df0:8500:ca00::41],
      },
      management: {
        name: 'me0',
        path: '*14.0-usb-0:*:1.0',
        duid: '00:00:ba:2c:33:00:41',
      },
      underlay: {
        name: 'enp3s0',
        ipv6_token: 'static:::8888:aaaa:0:1',
      },
      downstream: {
        name: 'enp2s0',
        local_as: 65081,
        peer_as: 65030,
        link4: {
          local: '10.33.22.45',
          peer: '10.33.22.44',
        },
        link6: {
          local: '2001:df0:8500:ca22:44::b',
          peer: '2001:df0:8500:ca22:44::a',
        },
      },
    },
    tunnels: {
      wg_wire03: {
        listen_port: 8703,
        peer_endpoint: 'rknet-wire-03.i.open.ad.jp:8701',
        peer_public_key: 'lJuF/78NB3DJpFIErUopDfgiBDopSC5OrHN8xYCCbRg=',
        local_as: 65081,
        peer_as: 65082,
        link4: {
          local: '10.33.22.90',
          peer: '10.33.22.91',
        },
        link6: {
          local: '2001:df0:8500:ca22:90::a',
          peer: '2001:df0:8500:ca22:90::b',
        },
      },
      wg_wire04: {
        listen_port: 8704,
        peer_endpoint: 'rknet-wire-04.i.open.ad.jp:8701',
        peer_public_key: 'nmAg3RJdbKNiOjCt85iZGs6jFqPpMkHWLpgbhGVw0zo=',
        local_as: 65081,
        peer_as: 65082,
        link4: {
          local: '10.33.22.92',
          peer: '10.33.22.93',
        },
        link6: {
          local: '2001:df0:8500:ca22:92::a',
          peer: '2001:df0:8500:ca22:92::b',
        },
      },
      wg_wire99: {
        listen_port: 8799,
        peer_public_key: 'txcw4lC+WltZeGd6lmCm6vIN8uXtKZHCi3pPuxJ+8x4=',
        local_as: 65081,
        peer_as: 65080,
        link4: {
          local: '10.33.22.153',
          peer: '10.33.22.152',
        },
        link6: {
          local: '2001:df0:8500:ca22:152::b',
          peer: '2001:df0:8500:ca22:152::a',
        },
      },
    },
  },
)

include_role 'wire'
include_cookbook 'bluetooth-getty'
