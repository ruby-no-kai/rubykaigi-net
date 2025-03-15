{
  apiVersion: 'monitoring.coreos.com/v1alpha1',
  kind: 'ScrapeConfig',
  metadata: {
    name: 'tito',
    labels: {
      release: 'kube-prometheus-stack',
    },
  },
  spec: {
    scrapeInterval: '60s',
    scrapeTimeout: '50s',
    metricsPath: '/prd/prometheus',
    scheme: 'HTTPS',
    params: {},
    relabelings: [
      {
        sourceLabels: ['__address__'],
        targetLabel: '__metrics_path__',
        replacement: '/prd/prometheus/$1',
      },
      {
        targetLabel: '__address__',
        replacement: 'rk-attendee-gate.s3.dualstack.us-west-2.amazonaws.com:443',
      },
      {
        sourceLabels: ['__param_target'],
        targetLabel: 'instance',
      },

    ],
    staticConfigs: [{
      targets: [
        'rubykaigi/2024',
        'rubykaigi/2025',
        'rubykaigi/2025-party',
      ],
    }],
  },
}
