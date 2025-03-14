{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'fluentd',
    labels: {
      'rubykaigi.org/app': 'syslog-fluentd',
    },
  },
  spec: {
    replicas: 2,
    selector: {
      matchLabels: { 'rubykaigi.org/app': 'syslog-fluentd' },
    },
    template: {
      metadata: {
        labels: { 'rubykaigi.org/app': 'syslog-fluentd' },
      },
      spec: {
        serviceAccountName: 'syslog',
        securityContext: {
          runAsUser: 9999,
          fsGroup: 9999,
        },
        containers: [
          {
            name: 'fluentd',
            resources: {
              requests: {
                cpu: '5m',
                memory: '192M',
              },
            },
            image: '005216166247.dkr.ecr.ap-northeast-1.amazonaws.com/fluentd:e1f9c57c4144a320e30e948642ddecf2f3500b99',
            args: ['--config', '/config/fluent.conf'],
            ports: [
              { name: 'syslog', containerPort: 5140, protocol: 'UDP' },
              { name: 'prom', containerPort: 24231 },
              { name: 'healthz', containerPort: 10068 },
              { name: 'forward', containerPort: 24224 },
            ],
            env: [
            ],
            volumeMounts: [
              { name: 'config', mountPath: '/config' },
            ],
            readinessProbe: {
              httpGet: { path: '/api/plugins.json', port: 10068, scheme: 'HTTP' },
            },
            livenessProbe: {
              httpGet: { path: '/api/plugins.json', port: 10068, scheme: 'HTTP' },
              failureThreshold: 2,
              periodSeconds: 3,
            },
          },
        ],
        volumes: [
          {
            name: 'config',
            configMap: {
              name: 'fluentd-config',
            },
          },
        ],
      },
    },
  },
}
