[
  {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'PodMonitor',
    metadata: {
      name: 'unbound',
      labels: {
        release: 'kube-prometheus-stack',
      },
    },
    spec: {
      selector: {
        matchLabels: {
          'rubykaigi.org/app': 'unbound',
        },
      },
      podMetricsEndpoints: [
        {
          port: 'prom',
        },
      ],
    },
  },
]
