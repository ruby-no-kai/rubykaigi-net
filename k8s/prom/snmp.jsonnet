local esws = [
  //'as-01.venue.rubykaigi.net',
  //'es-tra-01.venue.rubykaigi.net',
  //'es-tra-02.venue.rubykaigi.net',
  //'es-trb-01.venue.rubykaigi.net',
  //'es-ro1-01.venue.rubykaigi.net',
  //'es-ro6-01.venue.rubykaigi.net',
  //'es-re1-01.venue.rubykaigi.net',

  'cs-99.tkyk.rubykaigi.net',
];

local targets_hi = {
  ix: {
    modules: ['if_mib', 'bgp4', 'nec_ix'],
    auth: 'public',
    hosts: [
      'tun-01.hnd.rubykaigi.net',
      'tun-01.nrt.rubykaigi.net',
      'tun-01.itm.rubykaigi.net',
      'tun-01.venue.rubykaigi.net',
      'tun-02.venue.rubykaigi.net',
      // 'tun-03.venue.rubykaigi.net',
      'nat-41.venue.rubykaigi.net',
      'nat-42.venue.rubykaigi.net',

      'tun-99.tkyk.rubykaigi.net',
      'nat-49.tkyk.rubykaigi.net',

      'recon-01.nrt.rubykaigi.net',
    ],
  },
  cisco_esw: {
    modules: ['if_mib'],
    auth: 'public',
    hosts: esws,
  },
};

local targets_lo = {
  cisco_wlc: {
    modules: ['if_mib', 'cisco_wlc'],
    auth: 'public2',
    hosts: [
      'wlc-01.venue.rubykaigi.net',
    ],
  },
  cisco_wlc_tkyk: {
    modules: ['if_mib', 'cisco_wlc'],
    auth: 'tkyk',
    hosts: [
      'wlc-99.tkyk.rubykaigi.net',
    ],
  },
  juniper_srx: {
    modules: [
      'if_mib_juniper1',
      'if_mib_juniper2',
      'juniper_alarm',
      'juniper_chassis',
      'juniper_bgp',
    ],
    auth: 'public',
    hosts: [
      'br-01.hnd.rubykaigi.net',
      'br-01.nrt.rubykaigi.net',
      'br-01.itm.rubykaigi.net',

      'er-01.venue.rubykaigi.net',
      'er-02.venue.rubykaigi.net',

      'er-99.tkyk.rubykaigi.net',
    ],
  },
  juniper_ex: {
    modules: [
      'if_mib_juniper1',
      'if_mib_juniper2',
      'juniper_alarm',
      'juniper_chassis',
      'juniper_dom',
      'juniper_bgp',
      'juniper_virtualchassis',
    ],
    auth: 'public',
    hosts: [
      'cs-01.venue.rubykaigi.net',
    ],
  },
  cisco_esw: {
    modules: ['cisco_envmon', 'cisco_sensors'],
    auth: 'public',
    hosts: esws,
  },
};

local probes(name, targets, interval) =
  std.objectValues(std.mapWithKey(function(n, t)
    {
      apiVersion: 'monitoring.coreos.com/v1alpha1',
      kind: 'ScrapeConfig',
      metadata: {
        name: 'snmp-%s-%s' % [name, std.strReplace(n, '_', '-')],
        labels: {
          release: 'kube-prometheus-stack',
        },
      },
      spec: {
        scrapeInterval: std.format('%ds', interval),
        scrapeTimeout: std.format('%ds', interval - 1),
        metricsPath: '/snmp',
        params: {
          module: t.modules,
          auth: [t.auth],
        },
        relabelings: [
          {
            sourceLabels: ['__address__'],
            targetLabel: '__param_target',
          },
          {
            sourceLabels: ['__param_target'],
            targetLabel: 'instance',
          },
          {
            targetLabel: '__address__',
            replacement: 'snmp-exporter-prometheus-snmp-exporter.default.svc.cluster.local:9116',
          },
          import './relabel_instance_short.libsonnet',
        ],
        staticConfigs: [{
          targets: t.hosts,
        }],
      },
    }, targets));

probes('hi', targets_hi, 20) + probes('lo', targets_lo, 60)
