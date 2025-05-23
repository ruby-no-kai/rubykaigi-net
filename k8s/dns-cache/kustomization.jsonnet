{
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  namespace: 'default',
  resources: [
    './deployment.yml',
    './configmap.yml',
    './pdb.yml',
    './service.yml',
    './monitoring.yml',
  ],
}
