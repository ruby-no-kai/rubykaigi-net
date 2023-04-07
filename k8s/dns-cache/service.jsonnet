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
        { name: 'dns-tls', port: 853, targetPort: 'dns-tls', protocol: 'TCP' },
        { name: 'dns-https', port: 443, targetPort: 'dns-https', protocol: 'TCP' },
        { name: 'dns-https-udp', port: 443, targetPort: 'dns-https-udp', protocol: 'UDP' },
      ],
    },
  },
]
