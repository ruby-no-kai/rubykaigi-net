resource "helm_release" "snmp-exporter" {
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-snmp-exporter"
  version    = "5.1.0"

  name = "snmp-exporter"

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
    path = "./snmp-exporter.jsonnet"
  }
}

data "local_file" "snmp-exporter-config" {
  filename = "${path.module}/gen/snmp.yml"
}
