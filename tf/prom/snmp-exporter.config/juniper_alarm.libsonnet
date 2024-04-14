{
  modules: {
    juniper_alarm: {  // JUNIPER-ALARM-MIB
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
