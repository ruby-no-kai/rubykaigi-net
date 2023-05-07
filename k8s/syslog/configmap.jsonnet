[
  {
    apiVersion: 'v1',
    kind: 'ConfigMap',
    metadata: {
      name: 'fluentd-config',
    },
    data: {
      'fluent.conf': importstr './config/fluent.conf',
    },
  },
  {
    apiVersion: 'v1',
    kind: 'ConfigMap',
    metadata: {
      name: 'fluent-bit-config',
    },
    data: {
      'fluent-bit.conf': importstr './config/fluent-bit.conf',
      'fluent-bit-parsers.conf': importstr './config/fluent-bit-parsers.conf',
    },
  },
]
