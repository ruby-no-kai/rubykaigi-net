{
  modules: {
    cisco_envmon: {  // CISCO-ENVMON-MIB
      walk: [
        'ciscoEnvMonTemperatureStatusValue',
        'ciscoEnvMonFanState',
        'ciscoEnvMonSupplyState',
      ],
      lookups: [
        {
          source_indexes: ['ciscoEnvMonTemperatureStatusIndex'],
          lookup: 'ciscoEnvMonTemperatureStatusDescr',
        },
        {
          source_indexes: ['ciscoEnvMonFanStatusIndex'],
          lookup: 'ciscoEnvMonFanStatusDescr',
        },
        {
          source_indexes: ['ciscoEnvMonSupplyStatusIndex'],
          lookup: 'ciscoEnvMonSupplyStatusDescr',
        },
      ],
    },
  },
}
