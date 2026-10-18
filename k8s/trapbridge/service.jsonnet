{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    name: 'trapbridge',
  },
  spec: {
    // NLB listener and target group: //tf/trapbridge/elb.tf
    selector: {
      'rubykaigi.org/app': 'trapbridge',
    },
    ports: [
      { name: 'snmptrap', port: 162, targetPort: 'snmptrap', protocol: 'UDP' },
    ],
  },
}
