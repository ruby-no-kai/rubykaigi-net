{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'radius',
  },
  spec: {
    selector: {
      'rubykaigi.org/app': 'radius',
    },
    ports: [
      { name: 'radius', port: 1812, targetPort: 'radius', protocol: 'UDP' },
      { name: 'radius-udp', port: 1812, targetPort: 'radius-udp', protocol: 'TCP' },
    ],
  },
}
