local kp = import '../kp.libsonnet';

[kp.kubePrometheus.namespace] +
[
  kp.prometheusOperator[name]
  for name in std.objectFields(kp.prometheusOperator)
  if !std.startsWith(name, '0')
] +
[kp.kubePrometheus.prometheusRule] +
std.objectValues(kp.alertmanager) +
std.objectValues(kp.blackboxExporter) +
std.objectValues(kp.grafana) +
std.objectValues(kp.kubeStateMetrics) +
std.objectValues(kp.kubernetesControlPlane) +
std.objectValues(kp.nodeExporter) +
std.objectValues(kp.prometheus) +
std.objectValues(kp.prometheusAdapter)
