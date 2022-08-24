{
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  resources: [
    './deployment.yml',
    './configmap.yml',
    './serviceaccount.yml',
    './clusterrole.yml',
    './service.yml',
  ],
  images: [
    {
      name: 'ghcr.io/dexidp/dex',
      newName: 'ghcr.io/dexidp/dex',
      newTag: 'v2.33.0-distroless',
    },
  ],
}
