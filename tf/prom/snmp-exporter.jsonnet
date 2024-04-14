{
  resources: {
    requests: {
      cpu: '32m',
      memory: '32M',
    },
  },
  extraArgs: [
    '--snmp.module-concurrency=5',
  ],
}
