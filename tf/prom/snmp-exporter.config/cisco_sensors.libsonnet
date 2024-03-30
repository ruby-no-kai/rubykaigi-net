{
  modules: {
    cisco_sensors: {  // CISCO-ENTITY-SENSOR-MIB
      walk: [
        '1.3.6.1.4.1.9.9.91.1.1.1.1',  // entSensorValueEntry
      ],
      lookups: [
        {
          source_indexes: [
            'entPhysicalIndex',
          ],
          lookup: 'entPhysicalContainedIn',
        },
        {
          source_indexes: [
            'entPhysicalIndex',
          ],
          lookup: 'entPhysicalName',
        },
        {
          source_indexes: [
            'entPhysicalIndex',
          ],
          lookup: 'entPhysicalDescr',
        },
        // {
        //   source_indexes: [
        //     'entPhysicalIndex',  // '1.3.6.1.2.1.47.1.1.1.1.1',
        //   ],
        //   lookup: 'entPhysicalDescr',  // 1.3.6.1.2.1.47.1.1.1.1.7
        // },
        // {
        //   source_indexes: [
        //     'entPhysicalIndex',  // '1.3.6.1.2.1.47.1.1.1.1.1',
        //   ],
        //   lookup: 'entSensorType',
        // },
        // {
        //   source_indexes: [
        //     'entPhysicalIndex',  // '1.3.6.1.2.1.47.1.1.1.1.1',
        //   ],
        //   lookup: 'entSensorScale',
        // },
        // {
        //   source_indexes: [
        //     'entPhysicalIndex',  // '1.3.6.1.2.1.47.1.1.1.1.1',
        //   ],
        //   lookup: 'entSensorPrecision',
        // },
      ],
      overrides: {
        entSensorType: { type: 'EnumAsInfo' },
        entSensorScale: {
          regex_extracts: {
            '': [
              { regex: '^1$', value: '0.000000000000000000000001' },  // yocto
              { regex: '^2$', value: '0.000000000000000000001' },  // zepto
              { regex: '^3$', value: '0.000000000000000001' },  // atto
              { regex: '^4$', value: '0.000000000000001' },  // femto
              { regex: '^5$', value: '0.000000000001' },  // pico
              { regex: '^6$', value: '0.000000001' },  // nano
              { regex: '^7$', value: '0.000001' },  // micro
              { regex: '^8$', value: '0.001' },  // milli
              { regex: '^9$', value: '1' },  // units
              { regex: '^10$', value: '1000' },  // kilo
              { regex: '^11$', value: '1000000' },  // mega
              { regex: '^12$', value: '1000000000' },  // giga
              { regex: '^13$', value: '1000000000000' },  // tera
              { regex: '^14$', value: '1000000000000000' },  // peta
              { regex: '^15$', value: '1000000000000000000' },  // exa
              { regex: '^16$', value: '1000000000000000000000' },  // zetta
              { regex: '^17$', value: '1000000000000000000000000  ' },  // yotta
            ],
          },
        },
        entSensorValueUpdateRate: { ignore: true },
      },
    },
  },
}
