{
  apiVersion: 'monitoring.coreos.com/v1alpha1',
  kind: 'ScrapeConfig',
  metadata: {
    name: 'nat-6x',
    labels: {
      release: 'kube-prometheus-stack',
    },
  },
  spec: {
    scrapeInterval: '20s',
    scrapeTimeout: '15s',
    metricsPath: '/metrics',
    params: {},
    relabelings: [
      {
        sourceLabels: ['__address__'],
        targetLabel: 'instance',
        regex: '^(me0\\.)?(.+\\.rubykaigi\\.net)$',
        replacement: '$2',
      },
    ],
    staticConfigs: [{
      targets: [
        'me0.nat-61.venue.rubykaigi.net:9100',
        // 'me0.nat-62.venue.rubykaigi.net:9100',
      ],
    }],
  },
}
