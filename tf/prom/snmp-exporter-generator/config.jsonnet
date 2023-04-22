local modules = (import './if_mib.libsonnet').modules
                + (import './cisco_wlc.libsonnet').modules
                + (import './nec_ix.libsonnet').modules
;

{
  modules: {
    [k]: {
      auth: {
        community: 'public',
      },
      version: 2,
    } + modules[k]
    for k in std.objectFields(modules)
  },
}
