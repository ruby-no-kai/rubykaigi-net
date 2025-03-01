{
  apiVersion: 'karpenter.k8s.aws/v1',
  kind: 'EC2NodeClass',
  metadata: {
    name: error 'specify name',
  },
  spec: {
    amiFamily: 'Bottlerocket',
    amiSelectorTerms: [{ alias: 'bottlerocket@latest' }],

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
      Project: 'rk25net',
      Component: 'k8s',
      Role: 'kubelet/%s' % $.metadata.name,
      KarpenterNodeClass: $.metadata.name,
    },

    kubelet: {
      maxPods: $.max_pods,
      kubeReserved: {
        cpu: '70m',
        'ephemeral-storage': '1Gi',
        memory: '300Mi',
      },
    },
  },

  max_pods:: 110,
  subnet_tier:: 'private',
}
