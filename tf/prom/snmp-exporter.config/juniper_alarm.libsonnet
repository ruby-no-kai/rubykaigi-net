{
  modules: {
    juniper_alarm: (import './juniper_base_config.libsonnet') {  // JUNIPER-ALARM-MIB
      walk: [
        'jnxYellowAlarmState',
        'jnxYellowAlarmCount',
        'jnxYellowAlarmLastChange',
        'jnxRedAlarmState',
        'jnxRedAlarmCount',
        'jnxRedAlarmLastChange',
      ],
      lookups: [
      ],
      overrides: {
        jnxYellowAlarmState: { type: 'EnumAsStateSet' },
        jnxRedAlarmState: { type: 'EnumAsStateSet' },
      },
    },
  },
}
