{
  apiVersion: 'karpenter.sh/v1beta1',
  kind: 'NodePool',
  metadata: {
    name: error 'specify name',
  },
  spec: {
    weight: 10,
    template: {
      metadata: {
        labels: {
          'rubykaigi.org/node-group': $.metadata.name,
        },
      },
      spec: {

        nodeClassRef: { name: 'general' },

        taints: [],

        requirements: [
          {
            key: 'karpenter.k8s.aws/instance-category',
            operator: 'In',
            values: $.instance_category,
          },
          {
            key: 'kubernetes.io/arch',
            operator: 'In',
            values: $.arch,
          },
          {
            key: 'kubernetes.io/os',
            operator: 'In',
            values: ['linux'],
          },
          {
            key: 'karpenter.sh/capacity-type',
            operator: 'In',
            values: $.capacity_type,
          },
        ],

      },
    },
    disruption: {
      consolidationPolicy: 'WhenUnderutilized',
      expireAfter: '24h',
      budgets: [
        { nodes: '30%' },
      ],
    },
  },

  instance_category:: ['t'],
  arch:: ['arm64'],
  capacity_type:: ['spot', 'on-demand'],  // spot is prioritized: https://karpenter.sh/docs/concepts/nodepools/#capacity-type
}
