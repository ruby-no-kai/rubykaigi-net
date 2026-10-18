// Cisco Wireless LAN Controller
{
  modules: [
    'AIRESPACE-WIRELESS-MIB',
    'AIRESPACE-SWITCHING-MIB',
    'CISCO-LWAPP-AP-MIB',
    'CISCO-LWAPP-DOT11-MIB',
    'CISCO-LWAPP-DOT11-CLIENT-MIB',
    'CISCO-LWAPP-SYS-MIB',
    'CISCO-LWAPP-HA-MIB',
    'CISCO-LWAPP-RRM-MIB',
    'CISCO-LWAPP-ROGUE-MIB',
    'CISCO-LWAPP-MOBILITY-EXT-MIB',
  ],
  include: [
    'AIRESPACE-WIRELESS-MIB::bsnTraps',
    'AIRESPACE-SWITCHING-MIB::switchingTraps',
    'CISCO-LWAPP-AP-MIB::ciscoLwappApMIBNotifs',
    'CISCO-LWAPP-DOT11-MIB::ciscoLwappDot11MIBNotifs',
    'CISCO-LWAPP-DOT11-CLIENT-MIB::ciscoLwappDot11ClientMIBNotifs',
    'CISCO-LWAPP-SYS-MIB::ciscoLwappSysMIBNotifs',
    'CISCO-LWAPP-HA-MIB::ciscoLwappHaMIBNotifs',
    'CISCO-LWAPP-RRM-MIB::ciscoLwappRrmMIBNotifs',
    'CISCO-LWAPP-ROGUE-MIB::ciscoLwappRogueMIBNotifs',
    'CISCO-LWAPP-MOBILITY-EXT-MIB::ciscoLwappMobilityExtMIBNotifs',
  ],
  overrides: {},
}
