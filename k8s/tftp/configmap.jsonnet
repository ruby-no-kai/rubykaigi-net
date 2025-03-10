[
  {
    apiVersion: 'v1',
    kind: 'ConfigMap',
    metadata: {
      name: 'tftp-envoy',
    },
    data: {
      'envoy.json': std.manifestJson(import './config/envoy.libsonnet'),
    },
  },
]
