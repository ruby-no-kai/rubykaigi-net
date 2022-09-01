{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'fluentd-config',
  },
  data: {
    'fluent.conf': importstr './config/fluent.conf',
  },
}
