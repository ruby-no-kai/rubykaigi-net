function(args)

  local provisionPrivateDatasources = true;  // <- Disable this on first `tf apply`!
  local privateOrganizationId = 2;  // <- Create this organization from the web UI.

  local publicDatasources = [
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
    {
      name: 'CloudWatch',
      type: 'cloudwatch',
      access: 'proxy',
      jsonData: {
        authType: 'default',
        defaultRegion: 'ap-northeast-1',
        assumeRoleArn: args.role_public,
      },
    },
  ];

  local privateDatasources = std.map(
    function(ds) ds { orgId: privateOrganizationId },
    [
      {
        name: 'Prometheus (Private)',
        type: 'prometheus',
        url: 'http://prometheus-operated.default.svc.cluster.local:9090',
        access: 'proxy',
        isDefault: true,
      },
      {
        name: 'CloudWatch (Private)',
        type: 'cloudwatch',
        access: 'proxy',
        jsonData: {
          authType: 'default',
          defaultRegion: 'ap-northeast-1',
          assumeRoleArn: args.role_private,
        },
      },
    ],
  );

  local datasources = publicDatasources + (if provisionPrivateDatasources then privateDatasources else []);

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
    datasources: {
      'datasources.yml': {
        apiVersion: 1,

        // deleteDatasources: [
        //   { name: 'Alertmanager (Private)' },
        // ],

        datasources: datasources,
      },
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
