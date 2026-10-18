{
  modules: [
    'JUNIPER-MIB',
    'JUNIPER-DOM-MIB',
    'JUNIPER-VIRTUALCHASSIS-MIB',
    'BGP4-V2-MIB-JUNIPER',
    'JUNIPER-CFGMGMT-MIB',
    'JUNIPER-CHASSIS-CLUSTER-MIB',
  ],
  include: [
    'JUNIPER-SMI::jnxChassisTraps',
    'JUNIPER-SMI::jnxChassisOKTraps',
    'JUNIPER-SMI::jnxDomNotifications',
    'JUNIPER-SMI::jnxDomLaneNotifications',
    'JUNIPER-SMI::jnxVccpNotifications',
    'BGP4-V2-MIB-JUNIPER::jnxBgpM2BaseNotifications',
    'JUNIPER-SMI::jnxCmNotifications',
    'JUNIPER-CHASSIS-CLUSTER-MIB::jnxJsChassisClusterNotifications',
  ],
  overrides: {
    // Error code and subcode octets.
    'BGP4-V2-MIB-JUNIPER::jnxBgpM2PeerLastErrorReceived': { type: 'OctetString' },
  },
}
