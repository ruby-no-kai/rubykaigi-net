resource "helm_release" "snmp-exporter" {
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-snmp-exporter"
  version    = "1.2.0"

  name             = "snmp-exporter"
  namespace        = "monitoring"
  create_namespace = true

  values = [
    data.external.snmp-exporter-values.result.json,
    jsonencode({
      config = data.local_file.snmp-exporter-config.content,
    }),
  ]
}

data "external" "snmp-exporter-values" {
  program = ["../jsonnet.rb"]

  query = {
    path = "./snmp-exporter.values.jsonnet"
  }
}

data "local_file" "snmp-exporter-config" {
  filename = "${path.module}/gen/snmp.yml"
}
