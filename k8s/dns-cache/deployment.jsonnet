local commit = '68c205fb465740cafb045d628de1d64702cdb9b9';
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
        topologySpreadConstraints: [
          {
            maxSkew: 1,
            topologyKey: 'topology.kubernetes.io/zone',
            whenUnsatisfiable: 'ScheduleAnyway',
            labelSelector: {
              matchLabels: { 'rubykaigi.org/app': 'unbound' },
            },
          },
        ],
        containers: [
          {
            name: 'unbound',
            image: std.format('005216166247.dkr.ecr.ap-northeast-1.amazonaws.com/unbound:%s', commit),
            args: ['-c', '/etc/unbound/unbound.conf', '-dd'],
            ports: [
              { name: 'dns', containerPort: 10053, protocol: 'UDP' },
              { name: 'dns-tcp', containerPort: 10053, protocol: 'TCP' },
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
