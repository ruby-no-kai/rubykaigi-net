(import './nodepool.libsonnet') {
  metadata+: {
    name: 'onpremises',
  },
  spec+: {
    weight: 5,
    template+: {
      metadata+: {
      },
      spec+: {
        nodeClassRef+: { name: 'onpremises' },
        taints+: [
          {
            key: 'dedicated',
            value: 'onpremises',
            effect: 'NoSchedule',
          },
        ],
      },
    },
  },
}
