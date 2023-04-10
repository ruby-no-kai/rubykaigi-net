[
  {
    apiVersion: 'v1',
    kind: 'ConfigMap',
    metadata: {
      name: 'unbound-config',
    },
    data: {
      'unbound.conf': importstr './config/unbound.conf',
    },
  },
  {
    apiVersion: 'v1',
    kind: 'ConfigMap',
    metadata: {
      name: 'envoy-config',
    },
    data: {
      'envoy.json': std.manifestJson(import './config/envoy.libsonnet'),
    },
  },
]
