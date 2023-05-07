[
  {
    apiVersion: 'v1',
    kind: 'ServiceAccount',
    metadata: {
      name: 'fluent-bit',
    },
  },
  {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'ClusterRole',
    metadata: {
      name: 'fluent-bit',
    },
    rules: [
      {
        apiGroups: [''],
        resources: [
          'namespaces',
          'pods',
          'nodes',
          'nodes/proxy',
        ],
        verbs: [
          'get',
          'list',
          'watch',
        ],
      },
    ],
  },
  {
    apiVersion: 'rbac.authorization.k8s.io/v1',
    kind: 'ClusterRoleBinding',
    metadata: {
      name: 'fluent-bit',
    },
    roleRef: {
      apiGroup: 'rbac.authorization.k8s.io',
      kind: 'ClusterRole',
      name: 'fluent-bit',
    },
    subjects: [
      {
        kind: 'ServiceAccount',
        name: 'fluent-bit',
      },
    ],
  },
]
