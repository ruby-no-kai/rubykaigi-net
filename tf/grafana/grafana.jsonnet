function(args)
  {
    replicas: 2,
    resources: {
      requests: {
        cpu: '256m',
        memory: '256M',
      },
    },
    topologySpreadConstraints: [
      {
        labelSelector: {
          matchLabels: {
            'app.kubernetes.io/name': 'grafana',
            'app.kubernetes.io/instance': 'grafana',
          },
        },
        matchLabelKeys: [
          'pod-template-hash',
        ],
        maxSkew: 1,
        topologyKey: 'topology.kubernetes.io/zone',
        whenUnsatisfiable: 'ScheduleAnyway',
      },
    ],
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
      database: {
        type: 'mysql',
        host: 'grafana1.db.apne1.rubykaigi.net',
        name: 'grafana',
        user: '$__file{/var/run/secrets/mysql/username}',
        password: '$__file{/var/run/secrets/mysql/password}',
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
    extraSecretMounts: [
      {
        name: 'oidc-client',
        mountPath: '/var/run/secrets/oidc-client',
        secretName: 'grafana-oidc-client',
        readOnly: true,
      },
      {
        name: 'mysql',
        mountPath: '/var/run/secrets/mysql',
        secretName: 'grafana-mysql',
        readOnly: true,
      },
    ],
  }
