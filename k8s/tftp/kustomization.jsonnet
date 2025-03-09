{
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  namespace: 'default',
  resources: [
    './deployment.yml',
    './deployment_http.yml',
    './service.yml',
    './serviceaccount.yml',
    './configmap.yml',
  ],
}
