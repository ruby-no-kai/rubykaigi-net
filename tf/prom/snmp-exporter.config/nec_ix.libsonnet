{
  modules: {
    // NEC IX Router
    //
    // https://jpn.nec.com/univerge/ix/Manual/MIB/PICO-SMI-MIB.txt
    // https://jpn.nec.com/univerge/ix/Manual/MIB/PICO-SMI-ID-MIB.txt
    // https://jpn.nec.com/univerge/ix/Manual/MIB/PICO-IPSEC-FLOW-MONITOR-MIB.txt
    nec_ix: {
      walk: [
        'picoSystem',
        'picoExtIfMIB',
        'picoIPv4MIB',
        'picoIPv6MIB',
        'picoNAPTMIB',
        'bgpPeerState',
      ],
      lookups: [
        {
          source_indexes: ['picoExtIfInstalledSlot', 'picoExtIfIndex'],
          lookup: 'picoExtIfDescr',
        },
        {
          source_indexes: ['naptCacheIfIndex'],
          lookup: 'ifName',
        },
        {
          source_indexes: ['naptCacheIfIndex'],
          lookup: 'ifAlias',
        },
        {
          source_indexes: ['naptCacheIfIndex'],
          lookup: 'ifDescr',
        },
      ],
      overrides: {
        picoExtIfDescr: {
          ignore: true,
        },
        picoExtIfPhysicalAddress: {
          ignore: true,
        },
        picoExtIfType: {
          type: 'EnumAsInfo',
          ignore: true,
        },
      },
    },
  },
}
