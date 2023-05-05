{
  apiVersion: 'apps/v1',
  kind: 'DaemonSet',
  metadata: {
    name: 'fluent-bit',
    labels: {
      'rubykaigi.org/app': 'fluent-bit',
    },
  },
  spec: {
    selector: {
      matchLabels: {
        name: 'fluent-bit',
      },
    },
    template: {
      metadata: {
        labels: { name: 'fluent-bit' },
      },
      spec: {
        containers: [
          {
            name: 'fluent-bit',
            image: 'public.ecr.aws/aws-observability/aws-for-fluent-bit:2.31.10',
            args: ['--config', '/config/fluent-bit.conf', '--parser', '/config/fluent-bit-parsers.conf'],
            ports: [
              { name: 'healthcheck', containerPort: 2020 },
            ],
            volumeMounts: [
              { name: 'config', mountPath: '/config' },
            ],
            readinessProbe: {
              httpGet: { path: '/api/v1/health', port: 2020, scheme: 'HTTP' },
            },
            livenessProbe: {
              httpGet: { path: '/api/v1/health', port: 2020, scheme: 'HTTP' },
              failureThreshold: 2,
              periodSeconds: 3,
            },
          },
        ],
        volumes: [
          {
            name: 'config',
            configMap: { name: 'fluent-bit-config' },
          },
          {
            name: 'var-log-containers',
            hostPath: { path: '/var/log/containers', type: 'Directory' },
          },
          {
            name: 'var-lib-docker-containers',
            hostPath: { path: '/var/lib/docker/containers', type: 'Directory' },
          },
        ],
        hostNetwork: true,
        dnsPolicy: 'ClusterFirstWithHostNet',
      },
    },
  },
}
