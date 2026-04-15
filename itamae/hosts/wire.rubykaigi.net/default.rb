node.reverse_merge!(
  hocho_ec2: {},
  systemd_networkd: {
    migrate_netplan: false,
  },
  wire: {
    interfaces: {
      loopback: {
        address4: %w[10.33.0.49],
        address6: %w[2001:df0:8500:ca00::49],
      },
      management: {
        name: 'ens5',
        duid: '00:00:ba:2c:33:00:49',
      },
      overlay: {
        name: 'ens6',
        ipv6_token: 'static:::8888:9999:0:1',
        dhcpv4: true,
      },
      # downstream: {
      #   name: 'eth2',
      # },
    },
    kernel_route_table: 100,
    tunnels: {
      wg_wire03: {
        listen_port: 8703,
        peer_public_key: 'lJuF/78NB3DJpFIErUopDfgiBDopSC5OrHN8xYCCbRg=',
        local_as: 65088,
        peer_as: 65031,
        link4: {
          local: '10.33.22.150',
          peer: '10.33.22.151',
        },
        link6: {
          local: '2001:df0:8500:ca22:150::a',
          peer: '2001:df0:8500:ca22:150::b',
        },
      },
      wg_wire01: {
        listen_port: 8701,
        peer_endpoint: 'rknet-wire-01.i.open.ad.jp:8799',
        peer_public_key: 'gmhfxZ++XH+F+zMjSjqa3aaTb82vF0A5HyfmSa++Bnk=',
        local_as: 65088,
        peer_as: 65088,
        link4: {
          local: '10.33.22.152',
          peer: '10.33.22.153',
        },
        link6: {
          local: '2001:df0:8500:ca22:152::a',
          peer: '2001:df0:8500:ca22:152::b',
        },
      },
    },
  },
)

include_role 'wire'
