{
  modules: {
    juniper_jdhcp: (import './juniper_base_config.libsonnet') + {  // JUNIPER-JDHCP-MIB
      walk: [
        // 'jnxJdhcpLocalServerIfcStatsTable',
        'jnxJdhcpRelayIfcStatsTable',
      ],
      lookups: [
        // jnxJdhcpLocalServerIfcStatsIfIndex has a bug? it uses a value of interface index, not ifIndex
        // for instance, it returns "72" for: Logical interface reth0.100 (Index 71) (SNMP ifIndex 565)
        {
          source_indexes: ['ifIndex'],
          lookup: 'ifName',
        },
        {
          source_indexes: ['ifIndex'],
          lookup: 'ifDescr',
        },
      ],
      overrides: {},
    },
  },
}
