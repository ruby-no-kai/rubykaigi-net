{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'unbound-config',
  },
  data: {
    'unbound.conf': importstr './config/unbound.conf',
  },
}
