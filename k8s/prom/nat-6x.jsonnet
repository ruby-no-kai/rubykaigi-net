local hosts = [
  'me0.nat-61.venue.rubykaigi.net',
  'me0.nat-62.venue.rubykaigi.net',
];
local jobs = [
  {
    port:: 9100,
    metadata+: { name: 'nat-6x' },
  },
  {
    port:: 9324,
    metadata+: { name: 'nat-6x-bird' },
  },
  {
    port:: 9466,
    metadata+: { name: 'nat-6x-conntrack' },
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
      scrapeInterval: '20s',
      scrapeTimeout: '15s',
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
