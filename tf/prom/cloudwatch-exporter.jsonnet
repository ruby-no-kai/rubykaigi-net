{
  serviceAccount: {
    create: false,
    name: 'cloudwatch-exporter',
  },
  resources: {
    requests: {
      cpu: '5m',
      memory: '192M',
    },
  },
}
