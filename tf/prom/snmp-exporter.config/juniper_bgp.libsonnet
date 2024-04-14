{
  modules: {
    juniper_bgp: (import './juniper_base_config.libsonnet') + {  // BGP4-V2-MIB-JUNIPER
      walk: [
        'jnxBgpM2PeerState',
        'jnxBgpM2PeerStatus',
        'jnxBgpM2PeerInTotalMessages',
        'jnxBgpM2PeerOutTotalMessages',
        'jnxBgpM2PeerInUpdates',
        'jnxBgpM2PeerOutUpdates',
        'jnxBgpM2PrefixInPrefixes',
        'jnxBgpM2PrefixInPrefixesAccepted',
        'jnxBgpM2PrefixInPrefixesActive',
        'jnxBgpM2PrefixInPrefixesRejected',
        'jnxBgpM2PrefixOutPrefixes',
      ],
      lookups: [
        { source_indexes: ['jnxBgpM2PeerEntry'], lookup: 'jnxBgpM2PeerIndex' },
      ],
      overrides: {
        jnxBgpM2PeerState: { type: 'EnumAsStateSet' },
        jnxBgpM2PeerStatus: { type: 'EnumAsStateSet' },
        jnxBgpM2PeerIdentifier: { type: 'InetAddressMissingSize' },
        jnxBgpM2PeerLocalAddr: { type: 'InetAddressMissingSize' },
        jnxBgpM2PeerRemoteAddr: { type: 'InetAddressMissingSize' },
        jnxBgpM2PeerLocalAs: { type: 'EnumAsInfo' },
        jnxBgpM2PeerRemoteAs: { type: 'EnumAsInfo' },
      },
    },
  },
}
