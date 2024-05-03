{
  modules: {
    bgp4: {
      walk: [
        'bgpPeerState',
      ],
      lookups: [
      ],
      overrides: {
        bgpPeerState: { type: 'EnumAsStateSet' },
      },
    },
  },
}
