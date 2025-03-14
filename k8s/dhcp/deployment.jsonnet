local pod = (import './pod.libsonnet') {
  spec+: {
    topologySpreadConstraints: [
      {
        maxSkew: 1,
        topologyKey: 'topology.kubernetes.io/zone',
        whenUnsatisfiable: 'DoNotSchedule',
        labelSelector: {
          matchLabels: { 'rubykaigi.org/app': 'kea4' },
        },
        matchLabelKeys: [
          'pod-template-hash',
        ],
      },
    ],
  },
  app_container+:: {
    // serviceAccountName: 'kea4',
    resources: {
      requests: {
        cpu: '5m',
        memory: '20M',
      },
    },
    command: ['/bin/bash', '-e', '/app/run.sh'],
    ports: [
      { name: 'dhcp', containerPort: 67, protocol: 'UDP' },
      { name: 'prom', containerPort: 9547 },
      { name: 'healthz', containerPort: 10067 },
    ],
    readinessProbe: { httpGet: { path: '/healthz', port: 10067, scheme: 'HTTP' } },
    livenessProbe: {
      httpGet: { path: '/healthz', port: 10067, scheme: 'HTTP' },
      failureThreshold: 2,
      periodSeconds: 3,
    },
  },
};

{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'kea4',
    namespace: 'default',
    labels: {
      'rubykaigi.org/app': 'kea4',
    },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: { 'rubykaigi.org/app': 'kea4' },
    },
    template: {
      metadata: {
        labels: { 'rubykaigi.org/app': 'kea4' },
      },
      spec: pod.spec,
    },
  },
}
