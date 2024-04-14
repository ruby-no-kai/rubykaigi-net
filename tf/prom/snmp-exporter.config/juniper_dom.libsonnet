{
  modules: {
    juniper_dom: (import './juniper_base_config.libsonnet') + {  // JUNIPER-DOM-MIB
      walk: [
        'jnxDomCurrentAlarms',
        'jnxDomCurrentWarnings',
        'jnxDomCurrentRxLaserPower',
      ],
      lookups: [
        {
          source_indexes: [
            'ifIndex',
          ],
          lookup: 'ifAlias',
        },
        {
          source_indexes: [
            'ifIndex',
          ],
          lookup: '1.3.6.1.2.1.31.1.1.1.1',
        },
      ],
      overrides: {
        ifAlias: {
          ignore: true,
        },
        ifName: {
          ignore: true,
        },
      },
    },
  },
}
