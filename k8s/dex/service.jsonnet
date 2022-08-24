[
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: 'dex',
      namespace: 'default',
    },
    spec: {
      selector: {
        'rubykaigi.org/app': 'dex',
      },
      ports: [
        { name: 'http', port: 80, targetPort: 'http', protocol: 'TCP' },
      ],
    },
  },
  {
    apiVersion: 'elbv2.k8s.aws/v1beta1',
    kind: 'TargetGroupBinding',
    metadata: {
      name: 'dex',
      namespace: 'default',
    },
    spec: {
      targetGroupARN: 'arn:aws:elasticloadbalancing:ap-northeast-1:005216166247:targetgroup/rknw-common-dex/74c33fbfe89ba3ad',
      serviceRef: { name: 'dex', port: 80 },
    },
  },
]
