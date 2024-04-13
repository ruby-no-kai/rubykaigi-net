{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'resolver-rubykaigi-net',
  },
  spec: {
    secretName: 'cert-resolver-rubykaigi-net',
    dnsNames: [
      'resolver.rubykaigi.net',
    ],
    issuerRef: {
      kind: 'ClusterIssuer',
      name: 'letsencrypt-staging',
    },
  },
}
