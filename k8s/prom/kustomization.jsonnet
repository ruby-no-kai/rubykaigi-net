{
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  namespace: 'monitoring',
  resources: [
    './probes.yml',
  ],
}
