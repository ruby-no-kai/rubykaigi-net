[
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'kea4',
      namespace: 'default',
    },
    spec: {
      selector: {
        'rubykaigi.org/app': 'kea4',
      },
      ports: [
        { name: 'dhcp', port: 67, targetPort: 'dhcp', protocol: 'UDP' },
      ],
    },
  },
]
