{
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  resources: [
    './crds.yml',
    './kube-prometheus.yml',
    // './blackbox.yml',
    // './snmp.yml',
    // './rules.yml',
  ],
}
