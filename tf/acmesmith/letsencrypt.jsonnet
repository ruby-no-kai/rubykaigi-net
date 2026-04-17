function(args) {
  staging:: args.staging,

  directory: (
    if $.staging
    then 'https://acme-staging-v02.api.letsencrypt.org/directory'
    else 'https://acme-v02.api.letsencrypt.org/directory'
  ),

  storage: {
    type: 'kubernetes_secrets',
    instance: if $.staging then 'letsencrypt-staging' else 'letsencrypt',
  },

  challenge_responders: [
    {
      s3: {
        bucket: args.bucket,
        prefix: 'rknet/acme-http-01/',
      },
      filter: {
        subject_name_cidr: [
          '192.50.220.164/31',
          '2001:df0:8500:ca6d:53::c/127',
        ],
      },
    },
    {
      route53: {
        hosted_zone_map: args.hosted_zone_map,
      },
    },
  ],
  profiles: [
    { name: 'shortlived' },
  ],

  post_issuing_hooks: (
    if $.staging
    then {}
    else {
      'resolver.rubykaigi.net': [
        {
          kubernetes_secret: {
            name: 'cert-resolver-rubykaigi-net',
          },
        },
        {
          kubernetes_rollout: {
            kind: 'Deployment',
            selector: 'rubykaigi.org/app=unbound',
          },
        },
        {
          kubernetes_rollout: {
            kind: 'Deployment',
            selector: 'rubykaigi.org/app=unbound-envoy',
          },
        },
      ],
    }
  ),
}
