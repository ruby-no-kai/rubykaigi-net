local config = {
  issuer: 'https://idp.rubykaigi.net',
  storage: {
    type: 'kubernetes',
    config: {
      inCluster: true,
    },
  },
  web: { http: '0.0.0.0:8080' },
  oauth2: {
    responseTypes: ['code', 'id_token'],
    skipApprovalScreen: true,
  },
  connectors: [
    {
      type: 'github',
      id: 'github',
      name: 'GitHub',
      config: {
        clientID: '$GITHUB_CLIENT_ID',
        clientSecret: '$GITHUB_CLIENT_SECRET',
        redirectURI: 'https://idp.rubykaigi.net/callback',
        orgs: [
          { name: 'ruby-no-kai', teams: ['rk22-orgz', 'rko-infra', 'rk-noc'] },
        ],
      },
    },
  ],
  staticClients: [
    // ALB
    {
      name: 'ops-lb',
      id: '5VM7b7zXTEcQA5zcW2wmY0PM7RK2W6yT5M6xglFj8SI',
      secret: 'rQHgwpnOwsUTpvp6QDttq2KNs53HMbtPp5k4Go307Ds',
      redirectURIs: [
        'https://amc.rubykaigi.net/oauth2/idpresponse',
        'https://grafana.rubykaigi.net/oauth2/idpresponse',
        'https://prometheus.rubykaigi.net/oauth2/idpresponse',
        'https://alertmanager.rubykaigi.net/oauth2/idpresponse',
        'https://wlc.rubykaigi.net/oauth2/idpresponse',
        'https://test.rubykaigi.net/oauth2/idpresponse',
      ],
    },
  ],
};

{
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'dex',
    namespace: 'default',
  },
  data: {
    'config.yml': std.manifestYamlDoc(config, indent_array_in_object=true),
  },
}
