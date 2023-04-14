// Run ./gen-snmp-exporter-config.rb to regenerate snmp.yml

local common = {
  auth: {
    community: 'public',
  },
  version: 2,
};

{
  modules: {
    // Default IF-MIB interfaces table with ifIndex.
    if_mib: common {
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

    // Cisco Wireless LAN Controller
    cisco_wlc: common {
      auth+: {
        community: 'public2',
      },
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

    // NEC IX Router
    //
    // https://jpn.nec.com/univerge/ix/Manual/MIB/PICO-SMI-MIB.txt
    // https://jpn.nec.com/univerge/ix/Manual/MIB/PICO-SMI-ID-MIB.txt
    // https://jpn.nec.com/univerge/ix/Manual/MIB/PICO-IPSEC-FLOW-MONITOR-MIB.txt
    nec_ix: common {
      walk: [
        'picoSystem',
        'picoIpSecFlowMonitorMIB',
        'picoExtIfMIB',
        'picoNetworkMonitorMIB',
        'picoIsdnMIB',
        'picoNgnMIB',
        'picoMobileMIB',
        'picoIPv4MIB',
        'picoIPv6MIB',
      ],
      lookups: [
        {
          source_indexes: ['picoExtIfInstalledSlot', 'picoExtIfIndex'],
          lookup: 'picoExtIfDescr',
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
