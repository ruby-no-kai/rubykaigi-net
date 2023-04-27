[
  {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'PodMonitor',
    metadata: {
      name: 'kea4',
      labels: {
        release: 'kube-prometheus-stack',
      },
    },
    spec: {
      selector: {
        matchLabels: {
          'rubykaigi.org/app': 'kea4',
        },
      },
      podMetricsEndpoints: [
        {
          port: 'prom',
        },
      ],
    },
  },
  {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'PrometheusRule',
    metadata: {
      name: 'dhcp-rules',
      labels: {
        release: 'kube-prometheus-stack',
      },
    },
    spec: {
      groups+: [
        {
          name: 'dhcp',
          rules: [
            {
              alert: 'KeaAddressPoolUtilization',
              expr: 'max by (subnet) (kea_dhcp4_addresses_assigned_total / kea_dhcp4_addresses_total) > 0.8',
              'for': '5m',
              labels: {
                severity: 'warning',
              },
              annotations: {
                summary: 'DHCP subnet {{$labels.subnet}}: Address pool utilization >80% for 5m',
              },
            },
            {
              alert: 'KeaAddressPoolUtilization',
              expr: 'max by (subnet) (kea_dhcp4_addresses_assigned_total / kea_dhcp4_addresses_total) > 0.9',
              'for': '5m',
              labels: {
                severity: 'critical',
              },
              annotations: {
                summary: 'DHCP subnet {{$labels.subnet}}: Address pool utilization >90% for 5m',
              },
            },
          ],
        },
      ],
    },
  },
]
