{
  modules: [
    'SNMPv2-MIB',
    'IF-MIB',
    'BGP4-MIB',
    'ENTITY-MIB',
  ],
  include: [
    'SNMPv2-MIB::snmpTraps',  // coldStart, warmStart, authenticationFailure
    'IF-MIB::linkDown',
    'IF-MIB::linkUp',
    'BGP4-MIB::bgpNotification',
    'BGP4-MIB::bgpTraps',
    'ENTITY-MIB::entityMIBTraps',

    // Vendors append these to linkUp/linkDown beyond the standard OBJECTS.
    'IF-MIB::ifDescr',
    'IF-MIB::ifType',
    'IF-MIB::ifName',
    'IF-MIB::ifAlias',
  ],
  overrides: {
    // Error code and subcode octets.
    'BGP4-MIB::bgpPeerLastError': { type: 'OctetString' },
  },
}
