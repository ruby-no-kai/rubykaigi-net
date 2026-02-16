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
      replicas: 4,
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
              whenUnsatisfiable: 'DoNotSchedule',
              labelSelector: {
                matchLabels: { 'rubykaigi.org/app': 'unbound' },
              },
              matchLabelKeys: [
                'pod-template-hash',
              ],
            },
          ],
          containers: [
            {
              name: 'unbound',
              resources: {
                requests: {
                  cpu: '5m',
                  memory: '128M',
                },
              },
              image: '005216166247.dkr.ecr.ap-northeast-1.amazonaws.com/unbound:924bebe030149dbd0f0a3c9d1b9e331cc8d02be9',
              args: ['-c', '/etc/unbound/unbound.conf', '-dd'],
              ports: [
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
            {
              name: 'dnsdist',
              resources: {
                requests: {
                  cpu: '5m',
                  memory: '32M',
                },
              },
              image: '005216166247.dkr.ecr.ap-northeast-1.amazonaws.com/dnsdist:924bebe030149dbd0f0a3c9d1b9e331cc8d02be9',
              args: ['-C', '/etc/dnsdist/dnsdist.lua', '--supervised', '--disable-syslog'],
              ports: [
                { name: 'dns', containerPort: 10053, protocol: 'UDP' },
                { name: 'dns-tcp', containerPort: 10053, protocol: 'TCP' },
                { name: 'dns-tls', containerPort: 10853, protocol: 'TCP' },
                { name: 'dns-quic', containerPort: 10853, protocol: 'UDP' },
                { name: 'prom-dnsdist', containerPort: 9823 },
              ],
              env: [
              ],
              volumeMounts: [
                { name: 'dnsdist-config', mountPath: '/etc/dnsdist', readOnly: true },
                { name: 'tls-cert', mountPath: '/secrets/tls-cert', readOnly: true },
              ],
              readinessProbe: {
                httpGet: { path: '/jsonstat?command=stats', port: 9823, scheme: 'HTTP' },
              },
              livenessProbe: {
                httpGet: { path: '/jsonstat?command=stats', port: 9823, scheme: 'HTTP' },
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
              name: 'dnsdist-config',
              configMap: {
                name: 'dnsdist-config',
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
      replicas: 4,
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
              whenUnsatisfiable: 'DoNotSchedule',
              labelSelector: {
                matchLabels: { 'rubykaigi.org/app': 'unbound-envoy' },
              },
              matchLabelKeys: [
                'pod-template-hash',
              ],
            },
          ],
          containers: [
            {
              name: 'envoy',
              resources: {
                requests: {
                  cpu: '5m',
                  memory: '32M',
                },
              },
              image: 'envoyproxy/envoy:v1.29.3',
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
