local commit = 'c866cffcabaa3fc91ea02228efc905645ab984f4';
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
    replicas: 3,
    selector: {
      matchLabels: { 'rubykaigi.org/app': 'kea4' },
    },
    template: {
      metadata: {
        labels: { 'rubykaigi.org/app': 'kea4' },
      },
      spec: {
        // serviceAccountName: 'kea4',
        containers: [
          {
            name: 'app',
            image: std.format('005216166247.dkr.ecr.ap-northeast-1.amazonaws.com/kea:%s', commit),
            command: ['/bin/bash', '-e', '/app/run.sh'],
            ports: [
              { name: 'dhcp', containerPort: 67, protocol: 'UDP' },
              { name: 'prom', containerPort: 9547 },
              { name: 'healthz', containerPort: 10067 },
            ],
            env: [
              { name: 'LEASE_DATABASE_USER', valueFrom: { secretKeyRef: { name: 'kea-mysql', key: 'username' } } },
              { name: 'LEASE_DATABASE_PASSWORD', valueFrom: { secretKeyRef: { name: 'kea-mysql', key: 'password' } } },
              { name: 'HOSTS_DATABASE_USER', valueFrom: { secretKeyRef: { name: 'kea-mysql', key: 'username' } } },
              { name: 'HOSTS_DATABASE_PASSWORD', valueFrom: { secretKeyRef: { name: 'kea-mysql', key: 'password' } } },

            ],
            volumeMounts: [
              { name: 'config', mountPath: '/config' },
            ],
            readinessProbe: { httpGet: { path: '/healthz', port: 10067, scheme: 'HTTP' } },
            livenessProbe: {
              httpGet: { path: '/healthz', port: 10067, scheme: 'HTTP' },
              failureThreshold: 2,
              periodSeconds: 3,
            },
          },
        ],
        volumes: [
          { name: 'config', configMap: { name: 'kea-config', items: [{ key: 'kea-dhcp4.json', path: 'kea-dhcp4.json' }] } },
        ],
      },
    },
  },
}
