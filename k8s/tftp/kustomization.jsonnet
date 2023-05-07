{
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  namespace: 'default',
  resources: [
    './deployment.yml',
    './service.yml',
    './serviceaccount.yml',
  ],
}
