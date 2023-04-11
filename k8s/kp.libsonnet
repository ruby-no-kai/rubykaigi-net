(import 'kube-prometheus/main.libsonnet') +
(import 'kube-prometheus/addons/managed-cluster.libsonnet') +
{
  values+:: {
    common+: {
      namespace: 'monitoring',
      platform: 'aws',
    },
    prometheus+: {
      name: 'default',
    },
  },
}
