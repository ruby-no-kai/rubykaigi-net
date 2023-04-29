(import './base.libsonnet') + {
  apt: {
    sources: {
      docker: {
        source: 'deb [signed-by=$KEY_FILE] https://download.docker.com/linux/ubuntu $RELEASE stable',
        key: importstr './files/docker.key',
      },
    },
  },

  package_update: true,
  packages: [
    'docker-ce',
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
