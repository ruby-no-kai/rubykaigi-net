local dns_probe(domain) =
  {
    [std.format('dns_udp_%s', domain)]: {
      prober: 'dns',
      timeout: '5s',
      dns: {
        transport_protocol: 'udp',
        query_name: domain,
        query_type: 'A',
      },
    },
    [std.format('dns_tcp_%s', domain)]: {
      prober: 'dns',
      timeout: '5s',
      dns: {
        transport_protocol: 'tcp',
        query_name: domain,
        query_type: 'A',
      },
    },
  };


{
  resources: {
    requests: {
      cpu: '5m',
      memory: '18M',
    },
  },
  podSecurityContext: {
    sysctls: [
      {
        name: 'net.ipv4.ping_group_range',
        value: '1000 1000',
      },
    ],
  },
  securityContext: {
    runAsGroup: 1000,
  },

  config: {
    modules: std.foldl(
      function(a, b) a + b,
      [
        {
          icmp: {
            prober: 'icmp',
          },
        },
        dns_probe('rubykaigi.org'),  // internal
        dns_probe('kmc.gr.jp'),  // external
      ],
      {},
    ),
  },
}
