{
  resources: {
    requests: {
      cpu: '32m',
      memory: '40M',
    },
  },
  extraArgs: [
    '--snmp.module-concurrency=5',
  ],
}
