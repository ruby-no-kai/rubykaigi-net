node.reverse_merge!(
  bird: {
    router_id: '10.33.100.75',
  },
  show: {
    addresses: {
      client4: '10.33.39.0/24',
      client4_range: '10.33.39.1-10.33.39.254',
      client6: '2001:df0:8500:ca5a::/64',
      client6_range: '2001:df0:8500:ca5a:1000:0000:0000:0000-2001:df0:8500:ca5a:1fff:ffff:ffff:fffe',
      client6_snat: '2001:df0:8500:ca5a:1::/68',

      server4: '192.50.220.175',
      server4_pref64n: '2001:df0:8500:ca64:a9:8200:' 'c032:dcaf',
      server6: '2001:df0:8500:ca5b::ffff',
      server6_cidr: '2001:df0:8500:ca5b::/64',
      server6_dnat: '2001:df0:8500:ca5b:0::/68',

      client4_internal: '169.254.0.75',
      client6_internal: '2001:df0:8500:ca5a:1::e0ee',
      server4_internal: '169.254.1.75',
      server6_internal: '2001:df0:8500:ca5b:1::e1ee',
    },
    interfaces: {
      management: {
        name: 'enp11s0f0',
        duid: '00:00:ba:2c:33:00:75',
      },
      servers: [
        {
          name: 'enp12s0f1',
          local_as: 65075,
          peer_as: 65010,
          link4: {
            peer: '10.33.22.80',
            local: '10.33.22.81',
          },
          link6: {
            peer: '2001:df0:8500:ca22:80::a',
            local: '2001:df0:8500:ca22:80::b',
          },
        },
        {
          name: 'enp5s0',
          local_as: 65075,
          peer_as: 65010,
          link4: {
            peer: '10.33.22.82',
            local: '10.33.22.83',
          },
          link6: {
            peer: '2001:df0:8500:ca22:82::a',
            local: '2001:df0:8500:ca22:82::b',
          },
        },
      ],
      client: {
        name: 'enp2s0',
        local_as: 65075,
        peer_as: 65030,
        link4: {
          peer: '10.33.22.84',
          local: '10.33.22.85',
        },
        link6: {
          peer: '2001:df0:8500:ca22:84::a',
          local: '2001:df0:8500:ca22:84::b',
        },
      },
    },
  },
)
include_role 'show'
