{
  persistence: {
    enabled: true,
  },
  datasources: {
    'prometheus.yml': {
      apiVersion: 1,
      datasources: [
        {
          name: 'Prometheus',
          type: 'prometheus',
          url: 'http://prometheus-operated.default.svc.cluster.local:9090',
          access: 'proxy',
          isDefault: true,
        },
        {
          name: 'Alertmanager',
          type: 'alertmanager',
          url: 'http://alertmanager-operated.default.svc.cluster.local:9093',
          access: 'proxy',
          jsonData: {
            implementation: 'prometheus',
          },
        },
      ],
    },
  },
  'grafana.ini': {
    'auth.proxy': {
      enabled: true,
      auto_sign_up: true,
      header_name: 'x-amzn-oidc-identity',
    },
    users: {
      auto_assign_org_role: 'Admin',
    },
  },
}
