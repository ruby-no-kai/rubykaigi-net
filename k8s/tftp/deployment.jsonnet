{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'tftp-s3tftpd',
    namespace: 'default',
    labels: {
      'rubykaigi.org/app': 'tftp-s3tftpd',
    },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: { 'rubykaigi.org/app': 'tftp-s3tftpd' },
    },
    template: {
      metadata: {
        labels: { 'rubykaigi.org/app': 'tftp-s3tftpd' },
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
            image: '005216166247.dkr.ecr.ap-northeast-1.amazonaws.com/s3tftpd-healthz:0295a7184621ccb740c486b5a6e517bf1aa1b3e7',
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
