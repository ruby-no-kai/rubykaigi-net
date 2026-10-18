[
  {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'PodMonitor',
    metadata: {
      name: 'trapbridge',
      labels: {
        release: 'kube-prometheus-stack',
      },
    },
    spec: {
      selector: {
        matchLabels: {
          'rubykaigi.org/app': 'trapbridge',
        },
      },
      podMetricsEndpoints: [
        {
          port: 'http',
          path: '/metrics',
        },
      ],
    },
  },
]
