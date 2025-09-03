resource "helm_release" "blackbox-exporter" {
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-blackbox-exporter"
  version    = "11.3.1" # 0.27.0

  name = "blackbox-exporter"

  values = [data.external.blackbox-exporter-values.result.json]
}

data "external" "blackbox-exporter-values" {
  program = ["../jsonnet.rb"]

  query = {
    path = "./blackbox-exporter.jsonnet"
  }
}
