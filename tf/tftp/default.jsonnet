local user_data = (import '../cloudconfig.base.libsonnet') + {
  bootcmd: [
    ['cloud-init-per', 'once', 'ssh-port', 'bash', '-c', '( echo Port 9922; echo Port 22 ) >> /etc/ssh/sshd_config.d/90-rk-port.conf && systemctl daemon-reload'],
  ],
  packages: [
    'iperf3',
    'mtr',
  ],
};
local autoinstall = {
  autoinstall: {
    version: 1,
    storage: {
      version: 2,
      layout: { name: 'lvm', 'sizing-policy': 'all', 'reset-partition': true },
    },
    network: {
      version: 2,
      renderer: 'networkd',
      ethernets: {
        ethernet: {
          match: { name: 'en*' },
          dhcp4: true,
          'emit-lldp': true,
          wakeonlan: true,
          'link-local': ['ipv6'],
          'accept-ra': true,
          'ra-overrides': {
            'use-dns': true,
            'use-domains': true,
          },
          'dhcp4-overrides': {
            'use-dns': true,
            'use-domains': true,
            'send-hostname': true,
            'use-hostname': true,
            'use-mtu': true,
          },
        },
      },
    },
    packages: [
      'ssh-import-id',
      'openssh-server',
    ],
    'user-data': user_data,
    timezone: 'Etc/UTC',
    updates: 'all',
    shutdown: 'reboot',
    'late-commands': [
      // Wait for at least one network interface to be routable.
      // Marking all interfaces 'optional' leads to ssh-import-id to fail, so instead we override systemd-networkd-wait-online.service.
      [
        'curtin',
        'in-target',
        '--',
        'bash',
        '-c',
        |||
          mkdir -p /etc/systemd/system/systemd-networkd-wait-online.service.d
          cat <<-EOF >/etc/systemd/system/systemd-networkd-wait-online.service.d/90-netplan-overrides.conf
          # rubykaigi-net//tf/tftp/default.jsonnet
          [Unit]
          ConditionPathIsSymbolicLink=/run/systemd/generator/network-online.target.wants/systemd-networkd-wait-online.service
          [Service]
          ExecStart=
          ExecStart=/lib/systemd/systemd-networkd-wait-online --ipv4 --any -o routable --timeout=30
          EOF
        |||,
      ],
    ],
    // NOTE: hidoi. https://img.sorah.jp/x/20250310_022803_n3hXRVez8R.png
    // reporting: {
    //  central: {
    //    type: 'rsyslog',
    //    destination: '@syslog.rubykaigi.net',
    //  },
    //},
  },
};

{
  cloud_config: autoinstall,
  user_data: std.format('#cloud-config\n%s\n', std.manifestYamlDoc(autoinstall)),
}
