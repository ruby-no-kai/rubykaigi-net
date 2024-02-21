{
  apiVersion: 'karpenter.k8s.aws/v1beta1',
  kind: 'EC2NodeClass',
  metadata: {
    name: error 'specify name',
  },
  spec: {
    amiFamily: 'Bottlerocket',

    subnetSelectorTerms: [
      {
        tags: {
          'kubernetes.io/cluster/rknet': 'shared',
          Tier: $.subnet_tier,
        },
      },
    ],

    securityGroupSelectorTerms: [
      {
        tags: {
          'kubernetes.io/cluster/rknet': 'owned',
          'aws:eks:cluster-name': 'rknet',
        },
      },
    ],

    // role: 'NetEksKarpenterNode-rknet',
    instanceProfile: 'NetEksKarpenterNode-rknet',

    tags: {
      Project: 'rk24net',
      Component: 'k8s',
      Role: 'kubelet',
      KarpenterNodeClass: $.metadata.name,
    },
  },

  subnet_tier:: 'private',
}
