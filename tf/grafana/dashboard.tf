# Always backup to s3://rk-infra/grafana/backup/current/
# Manual copy to s3://rk-infra/grafana/backup/rkYYnet/ when tearing down
# Automaticaly imported from s3://rk-infra/grafana/backup/rkYYnet/ at creation
# Imported dashboards are not overwritten in later tf applies


locals {
  grafana_dashboards = {
    "bird_rs"             = {},
    "dhcp"                = {},
    "dns"                 = {},
    "location"            = {},
    "overview"            = {},
    "ping"                = {},
    "prometheus"          = {},
    "v6mostly"            = {},
    "circuit_and_tunnels" = {},
  }
}

data "aws_s3_object" "dashboard" {
  for_each = local.grafana_dashboards

  bucket = "rk-infra"
  key    = "grafana/backup/rk26net/${each.key}.json"
}

resource "grafana_dashboard" "dashboard" {
  for_each = local.grafana_dashboards

  config_json = replace(coalesce(data.aws_s3_object.dashboard[each.key].body, "{}\n"), "/\\$${DS_PROMETHEUS}/", grafana_data_source.prometheus.uid)

  depends_on = [helm_release.grafana, aws_security_group_rule.grafana-db_k8s-node]
  lifecycle {
    ignore_changes = [config_json]
  }
}

data "grafana_dashboard" "dashboard-backup" {
  for_each = local.grafana_dashboards
  uid      = grafana_dashboard.dashboard[each.key].uid

  depends_on = [helm_release.grafana, aws_security_group_rule.grafana-db_k8s-node]
}

resource "aws_s3_object" "dashboard-backup" {
  for_each = local.grafana_dashboards

  bucket = "rk-infra"
  key    = "grafana/backup/current/${each.key}.json"

  content      = replace(data.grafana_dashboard.dashboard-backup[each.key].config_json, "/\"uid\":\"${grafana_data_source.prometheus.uid}\"/", "\"uid\":\"$${DS_PROMETHEUS}\"")
  content_type = "application/json"

  provisioner "local-exec" {
    when        = destroy
    command     = <<-EOT
    aws s3 cp "s3://rk-infra/grafana/backup/current/$${NAME}.json" "s3://rk-infra/grafana/backup/last/$${NAME}.json"
    EOT
    environment = { NAME = each.key }
  }
}
