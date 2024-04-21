function(args)
  {
    resources: {
      requests: {
        cpu: '5m',
        memory: '64M',
      },
    },
    persistence: {
      enabled: true,
    },
    deploymentStrategy: {
      type: 'Recreate',  // For PVC
    },
    plugins: [
      'knightss27-weathermap-panel',
    ],
    admin: {
      existingSecret: 'grafana-admin',
      userKey: 'username',
      passwordKey: 'password',
    },
    'grafana.ini': {
      server: {
        root_url: 'https://grafana.rubykaigi.net/',
      },
      feature_toggles: {
        publicDashboards: true,
      },
      'auth.anonymous': {
        enabled: true,
        org_name: 'RubyKaigi',
        org_role: 'Viewer',
      },
    },
  }
