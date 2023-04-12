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
        dns_probe('google.com'),  // external
      ],
      {},
    ),
  },
}
