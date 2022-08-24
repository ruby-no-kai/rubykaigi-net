{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'dex',
    namespace: 'default',
    labels: {
      'rubykaigi.org/app': 'dex',
    },
  },
  spec: {
    replicas: 2,
    selector: {
      matchLabels: { 'rubykaigi.org/app': 'dex' },
    },
    template: {
      metadata: {
        labels: { 'rubykaigi.org/app': 'dex' },
      },
      spec: {
        serviceAccountName: 'dex',
        containers: [
          {
            name: 'app',
            image: 'ghcr.io/dexidp/dex:v2.30.0',
            command: ['/usr/local/bin/dex', 'serve', '/etc/dex/cfg/config.yml'],
            ports: [
              { name: 'http', containerPort: 8080 },
            ],
            env: [
              { name: 'GITHUB_CLIENT_ID', valueFrom: { secretKeyRef: { name: 'dex-github-client', key: 'client-id' } } },
              { name: 'GITHUB_CLIENT_SECRET', valueFrom: { secretKeyRef: { name: 'dex-github-client', key: 'client-secret' } } },
            ],
            volumeMounts: [
              { name: 'config', mountPath: '/etc/dex/cfg' },
            ],
            readinessProbe: { httpGet: { path: '/healthz', port: 8080, scheme: 'HTTP' } },
          },
        ],
        volumes: [
          { name: 'config', configMap: { name: 'dex', items: [{ key: 'config.yml', path: 'config.yml' }] } },
        ],
      },
    },
  },
}
