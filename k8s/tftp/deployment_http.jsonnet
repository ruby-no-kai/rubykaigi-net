{
  apiVersion: 'apps/v1',
  kind: 'Deployment',
  metadata: {
    name: 'tftp-envoy',
    labels: {
      'rubykaigi.org/app': 'tftp-envoy',
    },
  },
  spec: {
    replicas: 1,
    selector: {
      matchLabels: { 'rubykaigi.org/app': 'tftp-envoy' },
    },
    template: {
      metadata: {
        labels: { 'rubykaigi.org/app': 'tftp-envoy' },
      },
      spec: {
        serviceAccountName: 's3tftpd',
        containers: [
          {
            name: 'envoy',
            resources: {
              requests: {
                cpu: '5m',
                memory: '64M',
              },
            },
            image: 'envoyproxy/envoy:v1.33.0',
            // '-l', 'debug', '--component-log-level', 'aws:debug,filter:debug'
            args: ['--config-path', '/etc/envoy/envoy.json'],
            ports: [
              { name: 'http', containerPort: 11080, protocol: 'TCP' },
              { name: 'admin', containerPort: 9901 },
            ],
            env: [
              { name: 'AWS_EC2_METADATA_DISABLED', value: 'true' },
            ],
            volumeMounts: [
              { name: 'tftp-envoy', mountPath: '/etc/envoy', readOnly: true },
            ],
            readinessProbe: {
              httpGet: { path: '/ready', port: 9901, scheme: 'HTTP' },
            },
            livenessProbe: {
              httpGet: { path: '/ready', port: 9901, scheme: 'HTTP' },
              failureThreshold: 2,
              periodSeconds: 3,
            },
          },
        ],
        volumes: [
          {
            name: 'tftp-envoy',
            configMap: {
              name: 'tftp-envoy',
            },
          },
        ],
      },
    },
  },
}
