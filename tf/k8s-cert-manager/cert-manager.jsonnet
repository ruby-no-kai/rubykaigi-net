local resolvers = ['1.1.1.1:53', '8.8.8.8:53'];

{
  installCRDs: true,
  extraArgs: [
    '--dns01-recursive-nameservers-only',
    '--dns01-recursive-nameservers=' + std.join(',', resolvers),
  ],

  resources: {
    requests: {
      cpu: '5m',
      memory: '80M',
    },
  },

  cainjector: {
    resources: {
      requests: {
        cpu: '5m',
        memory: '128M',
      },
    },
  },

  webhook: {
    resources: {
      requests: {
        cpu: '5m',
        memory: '12M',
      },
    },
  },
}
