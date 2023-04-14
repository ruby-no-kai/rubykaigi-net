local targets = [
  {
    modules: ['if_mib', 'nec_ix'],
    hosts: [
      'br-01.hnd.rubykaigi.net',
      'br-01.nrt.rubykaigi.net',
      'tun-01.venue.rubykaigi.net',
      'tun-02.venue.rubykaigi.net',
      'gw-01.venue.rubykaigi.net',
      'gw-02.venue.rubykaigi.net',

      'tun-01.hot.rubykaigi.net',
      'gw-01.hot.rubykaigi.net',
      'tun-99.tkyk.rubykaigi.net',
      'gw-99.tkyk.rubykaigi.net',
    ],
  },
  {
    modules: ['if_mib'],
    hosts: [
      'sw-tra-01.venue.rubykaigi.net',
      'sw-tra-02.venue.rubykaigi.net',
      'sw-foa-01.venue.rubykaigi.net',
      'sw-trb-01.venue.rubykaigi.net',
      'sw-trb-02.venue.rubykaigi.net',
      'sw-fob-01.venue.rubykaigi.net',
      'sw-org-01.venue.rubykaigi.net',
      'sw-exp-01.venue.rubykaigi.net',
      'sw-con-01.venue.rubykaigi.net',
    ],
  },
];

local targets_lo = [
  {
    modules: ['if_mib2', 'cisco_wlc'],
    hosts: [
      'wlc-01.venue.rubykaigi.net',
    ],
  },
  {
    modules: ['if_mib'],
    hosts: [
      'csw-01.venue.rubykaigi.net',
    ],
  },

];

local probes(name, targets, interval) =
  local targetsByModule = std.foldl(function(result, t) result + {
    [module]+: t.hosts
    for module in t.modules
  }, targets, {});
  [
    {
      apiVersion: 'monitoring.coreos.com/v1',
      kind: 'Probe',
      metadata: {
        name: 'snmp-%s-%s' % [name, std.strReplace(module, '_', '-')],
        labels: {
          release: 'kube-prometheus-stack',
        },
      },
      spec: {
        interval: std.format('%ds', interval),
        scrapeTimeout: std.format('%ds', interval - 1),
        module: module,
        prober: {
          url: 'snmp-exporter-prometheus-snmp-exporter.default.svc.cluster.local:9116',
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
  ];

std.flattenArrays([
  probes('hi', targets, 20),
  probes('lo', targets_lo, 60),
])
