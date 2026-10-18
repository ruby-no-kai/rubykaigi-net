// NEC IX Router
//
// https://jpn.nec.com/univerge/ix/Manual/MIB/PICO-SMI-MIB.txt
// https://jpn.nec.com/univerge/ix/Manual/MIB/PICO-IPSEC-FLOW-MONITOR-MIB.txt
{
  modules: [
    'PICO-SMI',
    'PICO-IPSEC-FLOW-MONITOR-MIB',
  ],
  include: [
    // SMIv1 traps with ENTERPRISE pico; net-snmp names this node "pico#".
    '1.3.6.1.4.1.119.1.84.0',
    'PICO-SMI::picoNetmonMIBNotificationPrefix',
    'PICO-SMI::picoPostMIBNotificationPrefix',
    'PICO-IPSEC-FLOW-MONITOR-MIB::pipSecMIBNotificationPrefix',
  ],
  overrides: {
    // IPSIpAddress is a bare OCTET STRING (SIZE(4 | 16)).
    'PICO-IPSEC-FLOW-MONITOR-MIB::pikePeerLocalAddr': { type: 'InetAddress' },
    'PICO-IPSEC-FLOW-MONITOR-MIB::pikePeerRemoteAddr': { type: 'InetAddress' },
  },
}
