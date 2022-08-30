local targets = [
  {
    modules: ['if_mib', 'cisco_wlc'],
    hosts: [
      'mgmt.wlc-01.venue.rubykaigi.net',
    ],
  },
  {
    modules: ['if_mib', 'nec_ix'],
    hosts: [
      'lo.br-01.hnd.rubykaigi.net',
      'lo.br-01.itm.rubykaigi.net',
    ],
  },
  {
    modules: ['if_mib'],
    hosts: [
    ],
  }
];

local targetsByModule = std.foldl(function(result, t) result + {
  [module]+: t.hosts for module in t.modules
}, targets, {});

[
  {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'Probe',
    metadata: {
      name: std.format('snmp-%s', std.strReplace(module, '_', '-')),
      labels: {
        release: 'kube-prometheus-stack',
      },
    },
    spec: {
      interval: '60s',
      module: module,
      prober: {
        url: 'snmp-exporter-prometheus-snmp-exporter.monitoring.svc.cluster.local:9116',
        path: '/snmp',
      },
      targets: {
        staticConfig: {
          static: targetsByModule[module],
        },
      },
    },
  }
  for module in std.objectFields(targetsByModule)
]
