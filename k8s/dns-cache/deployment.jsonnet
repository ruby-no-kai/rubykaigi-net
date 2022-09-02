local commit = '1e0447bdd6ddc2243f18c4f4e1e56af42f55c697';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'unbound',
    labels: {
      'rubykaigi.org/app': 'unbound',
    },
  },
  spec: {
    replicas: 2,
    selector: {
      matchLabels: { 'rubykaigi.org/app': 'unbound' },
    },
    template: {
      metadata: {
        labels: { 'rubykaigi.org/app': 'unbound' },
      },
      spec: {
        nodeSelector: {
          'rubykaigi.org/node-group': 'onpremises',
        },
        tolerations: [
          { key: 'dedicated', value: 'onpremises', effect: 'NoSchedule' },
        ],
        containers: [
          {
            name: 'unbound',
            image: std.format('005216166247.dkr.ecr.ap-northeast-1.amazonaws.com/unbound:%s', commit),
            args: ['-c', '/etc/unbound/unbound.conf', '-dd'],
            ports: [
              { name: 'dns', containerPort: 10053, protocol: 'UDP' },
              { name: 'prom', containerPort: 9167 },
            ],
            env: [
            ],
            securityContext: {
              capabilities: { add: ['NET_ADMIN'] },  // For SO_RCVBUFFORCE/SO_SNDBUFFORCE
            },
            volumeMounts: [
              { name: 'config', mountPath: '/etc/unbound', readOnly: true },
            ],
            readinessProbe: {
              httpGet: { path: '/healthz', port: 9167, scheme: 'HTTP' },
            },
            livenessProbe: {
              httpGet: { path: '/healthz', port: 9167, scheme: 'HTTP' },
              failureThreshold: 2,
              periodSeconds: 3,
            },
          },
        ],
        volumes: [
          {
            name: 'config',
            configMap: {
              name: 'unbound-config',
            },
          },
        ],
      },
    },
  },
}
