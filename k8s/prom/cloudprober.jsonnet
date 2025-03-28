{
  apiVersion: 'monitoring.coreos.com/v1alpha1',
  kind: 'ScrapeConfig',
  metadata: {
    name: 'cloudprober',
    labels: {
      release: 'kube-prometheus-stack',
    },
  },
  spec: {
    relabelings: [
      import './relabel_instance_short.libsonnet',
    ],
    dnsSDConfigs: [{
      names: ['_prometheus._http.cloudprober.rubykaigi.net'],
    }],
  },
}
