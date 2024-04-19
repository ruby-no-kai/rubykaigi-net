[
  {
    apiVersion: 'v1',
    kind: 'ConfigMap',
    metadata: {
      name: 'v6test-frr-config',
    },
    data: {
      'frr.conf': importstr './config/frr.conf',
    },
  },
]
