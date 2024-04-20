local commit_radiusd = '4ebf22aa0f75cea5183107dc5301cc91b89601e0';
local commit_freeradius_exporter = 'bf1b115eff0ec17dbc071416075fe99de4538d9b';
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
        topologySpreadConstraints: [
          {
            maxSkew: 1,
            topologyKey: 'topology.kubernetes.io/zone',
            whenUnsatisfiable: 'DoNotSchedule',
            labelSelector: {
              matchLabels: { 'rubykaigi.org/app': 'radius' },
            },
            matchLabelKeys: [
              'pod-template-hash',
            ],
          },
        ],
        containers: [
          {
            name: 'app',
            resources: {
              requests: {
                cpu: '5m',
                memory: '96M',
              },
            },
            image: std.format('005216166247.dkr.ecr.ap-northeast-1.amazonaws.com/radiusd:%s', commit_radiusd),
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
            resources: {
              requests: {
                cpu: '5m',
                memory: '10M',
              },
            },
            image: std.format('005216166247.dkr.ecr.ap-northeast-1.amazonaws.com/freeradius-exporter:%s', commit_freeradius_exporter),
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
