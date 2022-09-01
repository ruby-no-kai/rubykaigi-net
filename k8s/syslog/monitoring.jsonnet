[
  {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'PodMonitor',
    metadata: {
      name: 'fluentd',
      labels: {
        release: 'kube-prometheus-stack',
      },
    },
    spec: {
      selector: {
        matchLabels: {
          'rubykaigi.org/app': 'syslog-fluentd',
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
