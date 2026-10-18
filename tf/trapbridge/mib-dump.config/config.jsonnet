local sets = [
  import './generic.libsonnet',
  import './juniper.libsonnet',
  import './nec_ix.libsonnet',
  import './cisco.libsonnet',
  import './cisco_wlc.libsonnet',
];

{
  // Paths inside the //tf/trapbridge/mib-dump image.
  mib_dirs: [
    '/usr/share/snmp/mibs',
    '/var/lib/mibs/iana',
    '/var/lib/mibs/ietf',
  ],
  modules: std.flattenArrays([s.modules for s in sets]),
  include: std.flattenArrays([s.include for s in sets]),
  overrides: std.foldl(function(acc, s) acc + s.overrides, sets, {}),
}
