{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'trapbridge',
    labels: {
      'rubykaigi.org/app': 'trapbridge',
    },
  },
  spec: {
    replicas: 2,
    selector: {
      matchLabels: { 'rubykaigi.org/app': 'trapbridge' },
    },
    template: {
      metadata: {
        labels: { 'rubykaigi.org/app': 'trapbridge' },
      },
      spec: {
        serviceAccountName: 'trapbridge',
        topologySpreadConstraints: [
          {
            maxSkew: 1,
            topologyKey: 'topology.kubernetes.io/zone',
            whenUnsatisfiable: 'DoNotSchedule',
            labelSelector: {
              matchLabels: { 'rubykaigi.org/app': 'trapbridge' },
            },
            matchLabelKeys: [
              'pod-template-hash',
            ],
          },
        ],
        containers: [
          {
            name: 'trapbridge',
            resources: {
              requests: {
                cpu: '5m',
                memory: '32M',
              },
            },
            image: 'ghcr.io/sorah/trapbridge:24e33c312499705e5fabb93cfae840ebc7eccc30',
            args: [
              'server',
              '--listen=0.0.0.0:162',
              '--http-listen=0.0.0.0:10162',
              '--mib-json=/config/mibs.json',
              '--config=/config/config.json',
              '--event-bus=default',
              '--log-json',
            ],
            env: [
              { name: 'AWS_REGION', value: 'ap-northeast-1' },
            ],
            ports: [
              { name: 'snmptrap', containerPort: 162, protocol: 'UDP' },
              { name: 'http', containerPort: 10162 },
            ],
            volumeMounts: [
              { name: 'config', mountPath: '/config' },
            ],
            readinessProbe: {
              httpGet: { path: '/healthz', port: 'http', scheme: 'HTTP' },
            },
            livenessProbe: {
              httpGet: { path: '/healthz', port: 'http', scheme: 'HTTP' },
              failureThreshold: 2,
              periodSeconds: 3,
            },
          },
        ],
        volumes: [
          {
            name: 'config',
            configMap: {
              name: 'trapbridge-config',
            },
          },
        ],
      },
    },
  },
}
