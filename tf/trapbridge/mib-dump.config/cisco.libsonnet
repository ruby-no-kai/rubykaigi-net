// Cisco Catalyst
{
  modules: [
    'CISCO-ENVMON-MIB',
    'CISCO-CONFIG-MAN-MIB',
    'CISCO-ENTITY-FRU-CONTROL-MIB',
    'CISCO-ENTITY-SENSOR-MIB',
    'CISCO-STACKWISE-MIB',
    'CISCO-ERR-DISABLE-MIB',
  ],
  include: [
    'CISCO-ENVMON-MIB::ciscoEnvMonMIBNotificationPrefix',
    'CISCO-CONFIG-MAN-MIB::ciscoConfigManMIBNotificationPrefix',
    'CISCO-ENTITY-FRU-CONTROL-MIB::cefcFRUMIBNotificationPrefix',
    'CISCO-ENTITY-SENSOR-MIB::entitySensorMIBNotificationPrefix',
    'CISCO-STACKWISE-MIB::ciscoStackWiseMIBNotifs',
    'CISCO-ERR-DISABLE-MIB::ciscoErrDisableMIBNotifs',
  ],
  overrides: {},
}
