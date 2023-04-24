{
  persistence: {
    enabled: true,
  },
  deploymentStrategy: {
    type: 'Recreate',  // For PVC
  },
  plugins: [
    'knightss27-weathermap-panel',
  ],
  datasources: {
    'prometheus.yml': {
      apiVersion: 1,
      datasources: [
        {
          name: 'Prometheus',
          type: 'prometheus',
          url: 'http://prometheus-operated.default.svc.cluster.local:9090',
          access: 'proxy',
          isDefault: true,
        },
        {
          name: 'Alertmanager',
          type: 'alertmanager',
          url: 'http://alertmanager-operated.default.svc.cluster.local:9093',
          access: 'proxy',
          jsonData: {
            implementation: 'prometheus',
          },
        },
        {
          name: 'CloudWatch',
          type: 'cloudwatch',
          access: 'proxy',
          jsonData: {
            authType: 'default',
            defaultRegion: 'ap-northeast-1',
          },
        },
      ],
    },
  },
  'grafana.ini': {
    server: {
      root_url: 'https://grafana.rubykaigi.net/',
    },
  },
}
