[
  {
    kind: 'Probe',
    apiVersion: 'monitoring.coreos.com/v1',
    metadata: {
      name: 'icmp',
      labels: {
        release: 'kube-prometheus-stack',
      },
    },
    spec: {
      interval: '60s',
      module: 'icmp',
      prober: {
        url: 'blackbox-exporter-prometheus-blackbox-exporter.default.svc.cluster.local:9115',
      },
      targets: {
        staticConfig: {
          static: [
            '192.50.220.1',
          ],
        },
      },
    },
  },
]
