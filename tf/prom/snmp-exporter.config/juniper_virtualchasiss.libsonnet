{
  modules: {
    juniper_virtualchassis: (import './juniper_base_config.libsonnet') + {  // JUNIPER-VIRTUALCHASSIS-MIB
      walk: [
        'jnxVirtualChassisMemberUptime',
        'jnxVirtualChassisMemberRole',
      ],
      lookups: [
        { source_indexes: ['jnxVirtualChassisMemberId'], lookup: 'jnxVirtualChassisMemberModel' },
        { source_indexes: ['jnxVirtualChassisMemberId'], lookup: 'jnxVirtualChassisMemberMacAddBase' },
        { source_indexes: ['jnxVirtualChassisMemberId'], lookup: 'jnxVirtualChassisMemberSerialnumber' },
      ],
      overrides: {
        jnxVirtualChassisMemberRole: { type: 'EnumAsStateSet' },
      },
    },
  },
}
