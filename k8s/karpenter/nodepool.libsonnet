{
  apiVersion: 'karpenter.sh/v1',
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
        nodeClassRef: { name: 'general', group: 'karpenter.k8s.aws', kind: 'EC2NodeClass' },

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
          {
            key: 'node.kubernetes.io/instance-type',
            operator: 'NotIn',
            values: $.excluded_instance_types,
          },
        ],

        expireAfter: '24h',
      },
    },
    disruption: {
      consolidationPolicy: 'WhenEmptyOrUnderutilized',
      consolidateAfter: '1m',
      budgets: [
        { nodes: '30%' },
      ],
    },
  },

  instance_category:: ['t'],
  arch:: ['arm64'],
  capacity_type:: ['spot', 'on-demand'],  // spot is prioritized: https://karpenter.sh/docs/concepts/nodepools/#capacity-type
  excluded_instance_types:: [
    // Too small pod capacity (4)
    't4g.nano',
    't4g.micro',
  ],
}
