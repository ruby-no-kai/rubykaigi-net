local kp = import '../kp.libsonnet';

// Strip descriptions from OpenAPI schemata to workaround size limitation
// See: https://github.com/prometheus-operator/prometheus-operator/issues/4355
local
  strip(v) =
    if std.isObject(v) then {
      [f]: if f == 'properties' then
        stripProps(v[f]) else strip(v[f])
      for f in std.objectFields(v)
      if f != 'description'
    } else if std.isArray(v) then [
      strip(e)
      for e in v
    ] else v,
  stripProps(v) =
    if std.isObject(v) then {
      [f]: strip(v[f])
      for f in std.objectFields(v)
    } else if std.isArray(v) then [
      strip(e)
      for e in v
    ] else v;

[
  strip(kp.prometheusOperator[name])
  for name in std.objectFields(kp.prometheusOperator)
  if std.startsWith(name, '0')
]
