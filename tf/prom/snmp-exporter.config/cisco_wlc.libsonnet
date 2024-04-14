{
  modules: {
    // Cisco Wireless LAN Controller
    cisco_wlc: {
      walk: [
        '1.3.6.1.4.1.9.9.618.1.8',  // clsSysInfo
        '1.3.6.1.4.1.9.9.513.1.1.1.1.6',  // cLApUpTime
        '1.3.6.1.4.1.14179.2.1.1.1.38',  // bsnDot11EssNumberofMobileStations
        '1.3.6.1.4.1.14179.2.2.2.1.2',  // bsnAPIfType
        '1.3.6.1.4.1.14179.2.2.2.1.3',  // bsnAPIfPhyChannelAssignment
        '1.3.6.1.4.1.14179.2.2.2.1.4',  // bsnAPIfPhyChannelNumber
        '1.3.6.1.4.1.14179.2.2.2.1.5',  // bsnAPIfPhyTxPowerControl
        '1.3.6.1.4.1.14179.2.2.2.1.6',  // bsnAPIfPhyTxPowerLevel
        '1.3.6.1.4.1.14179.2.2.2.1.15',  // bsnApIfNoOfUsers
        '1.3.6.1.4.1.14179.2.2.6.1',  // bsnAPIfDot11CountersTable
        '1.3.6.1.4.1.14179.2.2.13.1.3',  // bsnAPIfLoadChannelUtilization
        '1.3.6.1.4.1.14179.2.2.15.1.21',  // bsnAPIfDBNoisePower
      ],
      lookups: [
        {
          source_indexes: ['bsnDot11EssIndex'],
          lookup: 'bsnDot11EssSsid',
          drop_source_indexes: true,
        },
        {
          source_indexes: ['bsnAPDot3MacAddress', 'bsnAPIfSlotId'],
          lookup: 'bsnAPIfType',
        },
        {
          source_indexes: ['bsnAPDot3MacAddress'],
          lookup: 'bsnAPName',
        },
        {
          source_indexes: ['cLApSysMacAddress'],
          lookup: 'cLApName',
        },
      ],
      overrides: {
        bsnAPName: {
          type: 'DisplayString',
        },
        bsnAPIfType: {
          type: 'EnumAsInfo',
          ignore: true,
        },
        ifName: {
          ignore: true,
        },
        cLApName: {
          ignore: true,
        },
      },
    },
  },
}
