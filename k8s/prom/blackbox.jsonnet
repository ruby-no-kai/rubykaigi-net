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
        url: 'blackbox-exporter-prometheus-blackbox-exporter.monitoring.svc.cluster.local:9115',
      },
      targets: {
        staticConfig: {
          static: [
            '8.8.8.8',
          ],
        },
      },
    },
  }
]
