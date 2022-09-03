[
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'unbound',
    },
    spec: {
      selector: {
        'rubykaigi.org/app': 'unbound',
      },
      ports: [
        { name: 'dns', port: 53, targetPort: 'dns', protocol: 'UDP' },
        { name: 'dns-tcp', port: 53, targetPort: 'dns-tcp', protocol: 'TCP' },
      ],
    },
  },
]
