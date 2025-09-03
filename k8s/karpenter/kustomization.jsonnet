{
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  resources: [
    './nodeclass_general.yml',
    './nodeclass_onpremises.yml',
    './nodepool_general.yml',
    './nodepool_onpremises.yml',
    './ebs_gp3.yml',
  ],
}
