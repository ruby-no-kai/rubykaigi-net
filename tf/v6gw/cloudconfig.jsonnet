(import '../cloudconfig.base.libsonnet') {
  apt: {
    sources: {
      nekomit: {
        source: 'deb https://deb.nekom.it/ jammy main',
        key: importstr 'nekomit.key',
      },
    },
  },

  packages: [
    {
      apt: [
        'mitamae',
        'zip',
      ],
    },
  ],
}
