{
  modules: {
    juniper_chassis: {  // JUNIPER-MIB
      walk: [
        'jnxOperatingTable',
      ],
      lookups: [
        {
          source_indexes: [
            'jnxOperatingContentsIndex',
            'jnxOperatingL1Index',
            'jnxOperatingL2Index',
            'jnxOperatingL3Index',
          ],
          lookup: 'jnxOperatingDescr',
          drop_source_indexes: true,
        },
      ],
      overrides: {
        jnxOperatingContentsIndex: { ignore: true },
        jnxOperatingL1Index: { ignore: true },
        jnxOperatingL2Index: { ignore: true },
        jnxOperatingL3Index: { ignore: true },
        jnxOperatingState: { type: 'EnumAsStateSet' },
        jnxOperatingStateOrdered: { ignore: true },
      },
    },
  },
}
