[
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'fluentd',
    },
    spec: {
      type: 'ClusterIP',
      selector: {
        'rubykaigi.org/app': 'syslog-fluentd',
      },
      ports: [
        { name: 'syslog', port: 514, targetPort: 'syslog', protocol: 'UDP' },
      ],
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'fluentd-forward',
    },
    spec: {
      type: 'ClusterIP',
      selector: {
        'rubykaigi.org/app': 'syslog-fluentd',
      },
      ports: [
        { name: 'forward', port: 24224, targetPort: 24224, protocol: 'TCP' },
      ],
    },
  },
]
