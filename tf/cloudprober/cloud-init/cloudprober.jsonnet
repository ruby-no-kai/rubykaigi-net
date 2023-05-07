(import './base.libsonnet') + {
  package_update: true,
  packages: [
    'docker.io',
  ],

  write_files: [
    {
      path: '/etc/cloudprober.cfg',
      permissions: '0644',
      content: importstr './files/cloudprober.cfg',
    },
    {
      path: '/etc/systemd/system/cloudprober.service',
      permissions: '0644',
      content: importstr './files/cloudprober.service',
    },
  ],

  runcmd: [
    ['systemctl', 'daemon-reload'],
    ['systemctl', 'enable', '--now', 'cloudprober.service'],
  ],
}
