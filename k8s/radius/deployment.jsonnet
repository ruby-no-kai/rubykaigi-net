local commit = 'c26454c2e2bebc5de663760e040b070490f5a861';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'radius',
    namespace: 'default',
    labels: {
      'rubykaigi.org/app': 'radius',
    },
  },
  spec: {
    replicas: 3,
    selector: {
      matchLabels: { 'rubykaigi.org/app': 'radius' },
    },
    template: {
      metadata: {
        labels: { 'rubykaigi.org/app': 'radius' },
      },
      spec: {
        // serviceAccountName: 'radius',
        containers: [
          {
            name: 'app',
            image: std.format('005216166247.dkr.ecr.ap-northeast-1.amazonaws.com/radiusd:%s', commit),
            command: ['/run.sh'],
            ports: [
              { name: 'radius', containerPort: 1812, protocol: 'UDP' },
              { name: 'radius-tcp', containerPort: 1812, protocol: 'TCP' },
            ],
            env: [
              { name: 'RADIUS_SECRET', valueFrom: { secretKeyRef: { name: 'radius', key: 'secret' } } },
            ],
            volumeMounts: [
              { name: 'tls-cert', mountPath: '/secrets/tls-cert' },
            ],
          },
          {
            name: 'exporter',
            image: std.format('005216166247.dkr.ecr.ap-northeast-1.amazonaws.com/freeradius-exporter:%s', commit),
            command: ['/usr/local/bin/freeradius_exporter'],
            ports: [
              { name: 'prom', containerPort: 9812, protocol: 'TCP' },
            ],
            env: [
              { name: 'RADIUS_SECRET', value: 'maplenutbunny' },
            ],
            readinessProbe: { httpGet: { path: '/metrics', port: 9812, scheme: 'HTTP' } },
            livenessProbe: {
              httpGet: { path: '/metrics', port: 9812, scheme: 'HTTP' },
              failureThreshold: 2,
              periodSeconds: 45,
            },
          },
        ],
        volumes: [
          {
            name: 'tls-cert',
            secret: {
              secretName: 'cert-radius',  // certificate.jsonnet
            },
          },
        ],
      },
    },
  },
}
