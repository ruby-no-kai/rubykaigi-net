[
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'tftp-s3tftpd',
    },
    spec: {
      selector: {
        'rubykaigi.org/app': 'tftp-s3tftpd',
      },
      ports: [
        { name: 'tftp', port: 69, targetPort: 'tftp', protocol: 'UDP' },
      ],
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'tftp-envoy',
    },
    spec: {
      selector: {
        'rubykaigi.org/app': 'tftp-envoy',
      },
      ports: [
        { name: 'http', port: 80, targetPort: 'http', protocol: 'TCP' },
      ],
    },
  },
]
