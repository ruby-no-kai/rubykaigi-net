local modules =
  (import './if_mib.libsonnet').modules
  + (import './bgp4.libsonnet').modules
  + (import './cisco_envmon.libsonnet').modules
  + (import './cisco_sensors.libsonnet').modules
  + (import './cisco_wlc.libsonnet').modules
  + (import './juniper_alarm.libsonnet').modules
  + (import './juniper_bgp.libsonnet').modules
  + (import './juniper_chassis.libsonnet').modules
  + (import './juniper_dom.libsonnet').modules
  + (import './juniper_jdhcp.libsonnet').modules
  + (import './juniper_virtualchasiss.libsonnet').modules
  + (import './nec_ix.libsonnet').modules
;

{
  auths: {
    public: {
      version: 2,
      community: 'public',
    },
    public2: self.public {
      community: 'public2',
    },
    tkyk: self.public {
      community: 'T@koyakinek0',
    },
  },
  modules: {
    [k]: {
      max_repetitions: 25,
      retries: 3,
      timeout: '5s',
    } + modules[k]
    for k in std.objectFields(modules)
  },
}
