local blackboxExporterRelabelings = [
  {
    sourceLabels: ['__address__'],
    targetLabel: '__param_target',
  },
  {
    sourceLabels: ['__param_target'],
    targetLabel: 'instance',
  },
  {
    targetLabel: '__address__',
    replacement: 'blackbox-exporter-prometheus-blackbox-exporter.monitoring.svc.cluster.local:9115',
  },
  {
    targetLabel: '__metrics_path__',
    replacement: '/probe',
  },
];

local dnsProbes(domain) = [
  {
    port: 'dns',
    params: { module: ['dns_udp_rubykaigi.org'] },
    relabelings: blackboxExporterRelabelings,
    metricRelabelings: [
      {
        targetLabel: 'transport_protocol',
        replacement: 'udp',
      },
      {
        targetLabel: 'query_name',
        replacement: domain,
      },
    ],
  },
  {
    port: 'dns',
    params: { module: ['dns_tcp_rubykaigi.org'] },
    relabelings: blackboxExporterRelabelings,
    metricRelabelings: [
      {
        targetLabel: 'transport_protocol',
        replacement: 'tcp',
      },
      {
        targetLabel: 'query_name',
        replacement: domain,
      },
    ],
  },
];

[
  {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'PodMonitor',
    metadata: {
      name: 'unbound',
      labels: {
        release: 'kube-prometheus-stack',
      },
    },
    spec: {
      selector: {
        matchLabels: {
          'rubykaigi.org/app': 'unbound',
        },
      },
      podMetricsEndpoints: [
        {
          port: 'prom',
        },
      ],
    },
  },

  ///

  {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'PodMonitor',
    metadata: {
      name: 'unbound-resolv',
      labels: {
        release: 'kube-prometheus-stack',
      },
    },
    spec: {
      selector: {
        matchLabels: {
          'rubykaigi.org/app': 'unbound',
        },
      },
      podMetricsEndpoints: std.flattenArrays([
        dnsProbes('google.com'),
        dnsProbes('rubykaigi.org'),
      ]),
    },
  },
]
