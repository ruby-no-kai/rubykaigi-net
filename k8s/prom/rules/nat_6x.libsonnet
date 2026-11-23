{
  groups+: [
    {
      name: 'nat_6x',
      rules: [
        {
          alert: 'Nat6xTargetDown',
          expr: 'up{job=~"^scrapeConfig/default/nat-6x(-.+)?$"} == 0',
          'for': '3m',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: '{{$labels.job}}: scrape target down',
          },
        },
        {
          alert: 'Nat6xSiitTxDrop',
          expr: 'rate(node_network_transmit_drop_total{job="scrapeConfig/default/nat-6x",device="tun-siit"}[5m]) > 0',
          'for': '10m',
          labels: {
            severity: 'warning',
          },
          annotations: {
            summary: 'tun-siit tx drop continues 10m+ ({{$value | humanize}} pkt/s)',
          },
        },
        {
          alert: 'Nat6xConntrackDrop',
          expr: 'sum by (instance, instance_short) (rate(conntrack_drop_total{job="scrapeConfig/default/nat-6x-conntrack"}[5m])) > 5',
          'for': '5m',
          labels: {
            severity: 'warning',
          },
          annotations: {
            summary: 'conntrack drop > 5/s for 5m ({{$value | humanize}}/s)',
          },
        },
        {
          alert: 'Nat6xConntrackEarlyDrop',
          // Table full. KoR 2026: always 0.
          expr: 'sum by (instance, instance_short) (rate(conntrack_early_drop_total{job="scrapeConfig/default/nat-6x-conntrack"}[5m])) > 0',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: 'conntrack early_drop (table full?) ({{$value | humanize}}/s)',
          },
        },
        {
          alert: 'Nat6xConntrackTableUsage',
          expr: 'node_nf_conntrack_entries{job="scrapeConfig/default/nat-6x"} / node_nf_conntrack_entries_limit > 0.7',
          'for': '5m',
          labels: {
            severity: 'warning',
          },
          annotations: {
            summary: 'conntrack table usage > 70% ({{$value | humanizePercentage}})',
          },
        },
        {
          alert: 'Nat6xConntrackTableUsage',
          expr: 'node_nf_conntrack_entries{job="scrapeConfig/default/nat-6x"} / node_nf_conntrack_entries_limit > 0.9',
          'for': '1m',
          labels: {
            severity: 'critical',
          },
          annotations: {
            summary: 'conntrack table usage > 90% ({{$value | humanizePercentage}})',
          },
        },
      ],
    },
  ],
}
