{
  modules: {
    // Default IF-MIB interfaces table with ifIndex.
    if_mib: {
      walk: [
        'sysUpTime',
        'interfaces',
        'ifXTable',
      ],
      lookups: [
        {
          source_indexes: ['ifIndex'],
          lookup: 'ifAlias',
        },
        {
          source_indexes: ['ifIndex'],
          // Uis OID to avoid conflict with PaloAlto PAN-COMMON-MIB.
          lookup: '1.3.6.1.2.1.2.2.1.2',  // ifDescr
        },
        {
          source_indexes: ['ifIndex'],
          // Use OID to avoid conflict with Netscaler NS-ROOT-MIB.
          lookup: '1.3.6.1.2.1.31.1.1.1.1',  // ifName
        },
      ],
      overrides: {
        ifAlias: {
          ignore: true,  // Lookup metric
        },
        ifDescr: {
          ignore: true,  // Lookup metric
        },
        ifName: {
          ignore: true,  // Lookup metric
        },
        ifType: {
          type: 'EnumAsInfo',
        },
      },
    },

    if_mib2: self.if_mib {
      auth+: {
        community: 'public2',
      },
    },

    if_mib_juniper1: self.if_mib {
      walk: [
        'ifHCInOctets',
        'ifHCInUcastPkts',
        'ifHCInBroadcastPkts',
        'ifHCOutOctets',
        'ifHCOutUcastPkts',
        'ifHCOutBroadcastPkts',
      ],
    },
    if_mib_juniper2: self.if_mib {
      walk: [
        'ifAdminStatus',
        'ifOperStatus',
        'ifInDiscards',
        'ifInErrors',
        'ifOutDiscards',
        'ifOutErrors',
        'ifHighSpeed',
      ],
    },
  },
}
