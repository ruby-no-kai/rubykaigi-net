local modules = (import './if_mib.libsonnet').modules
                + (import './cisco_envmon.libsonnet').modules
                + (import './cisco_sensors.libsonnet').modules
                + (import './cisco_wlc.libsonnet').modules
                + (import './juniper_alarm.libsonnet').modules
                + (import './juniper_dom.libsonnet').modules
                + (import './nec_ix.libsonnet').modules
;

{
  modules: {
    [k]: {
      auth: {
        community: 'public',
      },
      version: 2,
      max_repetitions: 25,
      retries: 3,
      timeout: '5s',
    } + modules[k]
    for k in std.objectFields(modules)
  },
}
