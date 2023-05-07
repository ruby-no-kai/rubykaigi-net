[
  {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'PodMonitor',
    metadata: {
      name: 'radius',
      labels: {
        release: 'kube-prometheus-stack',
      },
    },
    spec: {
      selector: {
        matchLabels: {
          'rubykaigi.org/app': 'radius',
        },
      },
      podMetricsEndpoints: [
        {
          port: 'prom',
          path: '/metrics',
        },
      ],
    },
  },
]
