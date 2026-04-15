node.reverse_merge!(
  systemd_networkd: {
    migrate_netplan: false,
  },
  wire: {
    interfaces: {
      loopback: {
        address4: %w[10.33.0.43],
        address6: %w[2001:df0:8500:ca00::43],
      },
      management: {
        name: 'me0',
        path: '*14.0-usb-0:*:1.0',
        duid: '00:00:ba:2c:33:00:43',
      },
      overlay: {
        name: 'enp3s0',
        ipv6_token: 'static:::8888:cccc:0:1',
      },
      downstream: {
        name: 'enp2s0',
        # local_as: 65026,
        # peer_as: 65030,
        # link4: {
        #   local: '10.33.22.64',
        #   peer: '10.33.22.65',
        # },
        # link6: {
        #   local: '2001:df0:8500:ca22:64::a',
        #   peer: '2001:df0:8500:ca22:64::b',
        # },
      },
    },
    tunnels: {
      wg_wire01: {
        listen_port: 8701,
        peer_endpoint: 'rknet-wire-01.i.open.ad.jp:8703',
        peer_public_key: 'gmhfxZ++XH+F+zMjSjqa3aaTb82vF0A5HyfmSa++Bnk=',
        local_as: 65088,
        peer_as: 65088,
        link4: {
          local: '10.33.22.91',
          peer: '10.33.22.90',
        },
        link6: {
          local: '2001:df0:8500:ca22:90::b',
          peer: '2001:df0:8500:ca22:90::a',
        },
      },
    },
  },
)

include_role 'wire'
include_cookbook 'bluetooth-getty'
