local hosts = [
  'show-01.venue.rubykaigi.net',
];
local jobs = [
  {
    port:: 9100,
    metadata+: { name: 'show' },
  },
  {
    port:: 9324,
    metadata+: { name: 'show-bird' },
  },
];
[
  {
    apiVersion: 'monitoring.coreos.com/v1alpha1',
    kind: 'ScrapeConfig',
    metadata: {
      name: error 'specify job.metadata.name',
      labels: {
        release: 'kube-prometheus-stack',
      },
    },
    spec: {
      scrapeInterval: '10s',
      scrapeTimeout: '9s',
      metricsPath: '/metrics',
      params: {},
      relabelings: [
        {
          sourceLabels: ['__address__'],
          targetLabel: 'instance',
          regex: '^(me0\\.)?(.+\\.rubykaigi\\.net)(:.*)?$',
          replacement: '$2',
        },
        import './relabel_instance_short.libsonnet',
      ],
      staticConfigs: [{
        targets: [
          '%s:%d' % [
            host,
            job.port,
          ]
          for host in hosts
        ],
      }],
    },
  } + job
  for job in jobs
]
