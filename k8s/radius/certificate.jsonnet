{
  apiVersion: 'cert-manager.io/v1',
  kind: 'Certificate',
  metadata: {
    name: 'radius',
  },
  spec: {
    secretName: 'cert-radius',
    dnsNames: [
      'welcome.rubykaigi.org',
      'radius.rubykaigi.net',
    ],
    issuerRef: {
      kind: 'ClusterIssuer',
      name: 'letsencrypt',
    },
  },
}
