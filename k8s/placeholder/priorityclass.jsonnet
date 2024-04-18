{
  apiVersion: 'scheduling.k8s.io/v1',
  kind: 'PriorityClass',
  metadata: {
    name: 'placeholder',
  },
  value: -1000,
  globalDefault: false,
}
