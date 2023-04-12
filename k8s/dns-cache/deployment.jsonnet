local commit = 'b400f4a7bbcb44c69dc0eff35afe0c86b577f144';

local tls_cert_secret = 'cert-resolver-rubykaigi-net';

[
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'unbound',
      labels: {
        'rubykaigi.org/app': 'unbound',
      },
    },
    spec: {
      replicas: 2,
      selector: {
        matchLabels: { 'rubykaigi.org/app': 'unbound' },
      },
      template: {
        metadata: {
          labels: { 'rubykaigi.org/app': 'unbound' },
        },
        spec: {
          nodeSelector: {
            'rubykaigi.org/node-group': 'onpremises',
          },
          tolerations: [
            { key: 'dedicated', value: 'onpremises', effect: 'NoSchedule' },
          ],
          topologySpreadConstraints: [
            {
              maxSkew: 1,
              topologyKey: 'topology.kubernetes.io/zone',
              whenUnsatisfiable: 'ScheduleAnyway',
              labelSelector: {
                matchLabels: { 'rubykaigi.org/app': 'unbound' },
              },
            },
          ],
          containers: [
            {
              name: 'unbound',
              image: std.format('005216166247.dkr.ecr.ap-northeast-1.amazonaws.com/unbound:%s', commit),
              args: ['-c', '/etc/unbound/unbound.conf', '-dd'],
              ports: [
                { name: 'dns', containerPort: 10053, protocol: 'UDP' },
                { name: 'dns-tcp', containerPort: 10053, protocol: 'TCP' },
                { name: 'dns-tls', containerPort: 10853, protocol: 'TCP' },
                { name: 'dns-h2', containerPort: 10443, protocol: 'TCP' },
                { name: 'prom', containerPort: 9167 },
              ],
              env: [
              ],
              securityContext: {
                capabilities: { add: ['NET_ADMIN'] },  // For SO_RCVBUFFORCE/SO_SNDBUFFORCE
              },
              volumeMounts: [
                { name: 'unbound-config', mountPath: '/etc/unbound', readOnly: true },
                { name: 'tls-cert', mountPath: '/secrets/tls-cert', readOnly: true },
              ],
              readinessProbe: {
                httpGet: { path: '/healthz', port: 9167, scheme: 'HTTP' },
              },
              livenessProbe: {
                httpGet: { path: '/healthz', port: 9167, scheme: 'HTTP' },
                failureThreshold: 2,
                periodSeconds: 3,
              },
            },
          ],
          volumes: [
            {
              name: 'unbound-config',
              configMap: {
                name: 'unbound-config',
              },
            },
            {
              name: 'tls-cert',
              secret: {
                secretName: tls_cert_secret,
              },
            },
          ],
        },
      },
    },
  },
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: 'unbound-envoy',
      labels: {
        'rubykaigi.org/app': 'unbound-envoy',
      },
    },
    spec: {
      replicas: 2,
      selector: {
        matchLabels: { 'rubykaigi.org/app': 'unbound-envoy' },
      },
      template: {
        metadata: {
          labels: { 'rubykaigi.org/app': 'unbound-envoy' },
        },
        spec: {
          topologySpreadConstraints: [
            {
              maxSkew: 1,
              topologyKey: 'topology.kubernetes.io/zone',
              whenUnsatisfiable: 'ScheduleAnyway',
              labelSelector: {
                matchLabels: { 'rubykaigi.org/app': 'unbound-envoy' },
              },
            },
          ],
          containers: [
            {
              name: 'envoy',
              image: 'envoyproxy/envoy:v1.25.4',
              args: ['--config-path', '/etc/envoy/envoy.json'],
              ports: [
                { name: 'dns-https', containerPort: 11443, protocol: 'TCP' },
                { name: 'dns-https-udp', containerPort: 11443, protocol: 'UDP' },
                { name: 'admin', containerPort: 9901 },
              ],
              env: [
              ],
              volumeMounts: [
                { name: 'envoy-config', mountPath: '/etc/envoy', readOnly: true },
                { name: 'tls-cert', mountPath: '/secrets/tls-cert', readOnly: true },
              ],
              readinessProbe: {
                httpGet: { path: '/ready', port: 9901, scheme: 'HTTP' },
              },
              livenessProbe: {
                httpGet: { path: '/ready', port: 9901, scheme: 'HTTP' },
                failureThreshold: 2,
                periodSeconds: 3,
              },
            },
          ],
          volumes: [
            {
              name: 'envoy-config',
              configMap: {
                name: 'envoy-config',
              },
            },
            {
              name: 'tls-cert',
              secret: {
                secretName: tls_cert_secret,
              },
            },
          ],
        },
      },
    },
  },
]
