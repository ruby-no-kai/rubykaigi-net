local commit = '9aa2ad08c61a0e5fbe298c6cd27e2f12652d6a7f';
{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 's3tftpd',
    namespace: 'default',
    labels: {
      'rubykaigi.org/app': 's3tftpd',
    },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: { 'rubykaigi.org/app': 's3tftpd' },
    },
    template: {
      metadata: {
        labels: { 'rubykaigi.org/app': 's3tftpd' },
      },
      spec: {
        serviceAccountName: 's3tftpd',
        containers: [
          {
            name: 'app',
            resources: {
              requests: {
                cpu: '5m',
                memory: '64M',
              },
            },
            image: 'ghcr.io/hanazuki/s3tftpd@sha256:22aabcfabc081287043744c4355c5d77f8d91062e42a877ad7c15eb35c9dc361',
            args: ['--blocksize=1300', 's3://rk-tftp/'],
            ports: [
              { name: 'tftp', containerPort: 69, protocol: 'UDP' },
            ],
            env: [
              { name: 'S3TFTPD_LISTEN_PORT', value: '69' },
              { name: 'AWS_REGION', value: 'ap-northeast-1' },
            ],
          },
          {
            name: 'healthz',
            resources: {
              requests: {
                cpu: '5m',
                memory: '10M',
              },
            },
            image: std.format('005216166247.dkr.ecr.ap-northeast-1.amazonaws.com/s3tftpd-healthz:%s', commit),
            command: ['/usr/local/bin/healthz'],
            ports: [
              { name: 'healthz', containerPort: 8080, protocol: 'TCP' },
            ],
            readinessProbe: { httpGet: { path: '/ping', port: 8080, scheme: 'HTTP' } },
            livenessProbe: {
              httpGet: { path: '/ping', port: 8080, scheme: 'HTTP' },
              failureThreshold: 2,
              periodSeconds: 45,
            },
          },
        ],
      },
    },
  },
}
