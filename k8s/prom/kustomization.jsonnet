{
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  resources: [
    './blackbox.yml',
    './snmp.yml',
    './cloudprober.yml',
    './rules.yml',
  ],
}
