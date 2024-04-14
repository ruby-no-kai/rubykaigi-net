[
  {
    kind: 'Probe',
    apiVersion: 'monitoring.coreos.com/v1',
    metadata: {
      name: 'icmp',
      labels: {
        release: 'kube-prometheus-stack',
      },
    },
    spec: {
      interval: '60s',
      module: 'icmp',
      prober: {
        url: 'blackbox-exporter-prometheus-blackbox-exporter.default.svc.cluster.local:9115',
      },
      targets: {
        staticConfig: {
          static: [
            // '192.50.220.1',
            // 'br-01.hnd.rubykaigi.net',
            // 'br-01.nrt.rubykaigi.net',
            // 'tun-01.venue.rubykaigi.net',
            // 'tun-02.venue.rubykaigi.net',
            // 'gw-01.venue.rubykaigi.net',
            // 'gw-02.venue.rubykaigi.net',
            // 'csw-01.venue.rubykaigi.net',
            // 'csw-02.venue.rubykaigi.net',
            // 'wlc-01.venue.rubykaigi.net',
            // 'asw-01.venue.rubykaigi.net',
            // 'esw-tra-01.venue.rubykaigi.net',
            // 'esw-tra-02.venue.rubykaigi.net',
            // 'esw-fow-01.venue.rubykaigi.net',
            // 'esw-foe-01.venue.rubykaigi.net',
            // 'esw-trb-01.venue.rubykaigi.net',
            // 'esw-tpk-01.venue.rubykaigi.net',
            // 'esw-tpk-02.venue.rubykaigi.net',
            // 'esw-trc-01.venue.rubykaigi.net',
            // 'esw-stu-01.venue.rubykaigi.net',
            // 'esw-con-01.venue.rubykaigi.net',
            // 'esw-org-01.venue.rubykaigi.net',
            // 'ge-0-0-23.csw-01.venue.rubykaigi.net',
            // 'ge-0-0-23.csw-02.venue.rubykaigi.net',
            // 'vlan-2046.csw-01.venue.rubykaigi.net',
            // 'vlan-2044.csw-02.venue.rubykaigi.net',
            // 'nat.gw-01.venue.rubykaigi.net',
            // 'nat.gw-02.venue.rubykaigi.net',
          ],
        },
      },
    },
  },
]
