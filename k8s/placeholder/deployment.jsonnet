// This deployment requests Karpenter to provision at least one node on each AZ
local placeholder = function(name)
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: std.format('placeholder-%s', name),
      labels: {
        'rubykaigi.org/app': 'placeholder',
        'rubykaigi.org/instance': name,
      },
    },
    spec: {
      replicas: 2,
      selector: {
        matchLabels: $.metadata.labels,
      },
      template: {
        metadata: {
          labels: $.metadata.labels,
        },
        spec: {
          topologySpreadConstraints: [
            {
              topologyKey: 'topology.kubernetes.io/zone',
              maxSkew: 1,
              minDomains: $.spec.replicas,
              whenUnsatisfiable: 'DoNotSchedule',
              labelSelector: {
                matchLabels: $.metadata.labels,
              },
              matchLabelKeys: [
                'pod-template-hash',
              ],
            },
          ],
          priorityClassName: 'placeholder',
          containers: [
            {
              name: 'pause',
              image: 'public.ecr.aws/eks-distro/kubernetes/pause:3.9',
            },
          ],
        },
      },
    },
  };


[
  placeholder('generic'),
  placeholder('onpremises') {
    spec+: {
      template+: {
        spec+: {
          nodeSelector: {
            'rubykaigi.org/node-group': 'onpremises',
          },
          tolerations: [
            { key: 'dedicated', value: 'onpremises', effect: 'NoSchedule' },
          ],
        },
      },
    },
  },
]
