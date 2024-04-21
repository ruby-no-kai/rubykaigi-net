provider "grafana" {
  url  = "https://grafana.rubykaigi.net/"
  auth = "admin:${random_password.grafana-admin.result}"
}

resource "grafana_organization" "rk-private" {
  name       = "RubyKaigi (ひみつだよ)"
  admin_user = "admin"
}

resource "grafana_data_source" "prometheus" {
  type = "prometheus"
  name = "Prometheus"
  url  = "http://prometheus-operated.default.svc.cluster.local:9090"

  is_default = true
}

resource "grafana_data_source" "alertmanager" {
  type = "alertmanager"
  name = "Alertmanager"
  url  = "http://alertmanager-operated.default.svc.cluster.local:9093"

  json_data_encoded = jsonencode({
    implementation = "prometheus",
  })
}

resource "grafana_data_source" "cloudwatch" {
  type = "cloudwatch"
  name = "cloudwatch"

  json_data_encoded = jsonencode({
    authType      = "default",
    defaultRegion = "ap-northeast-1",
    assumeRoleArn = aws_iam_role.grafana-public.arn,
  })
}

resource "grafana_data_source" "prometheus-private" {
  org_id = grafana_organization.rk-private.org_id

  type = "prometheus"
  name = "Prometheus"
  url  = "http://prometheus-operated.default.svc.cluster.local:9090"

  is_default = true
}

resource "grafana_data_source" "cloudwatch-private" {
  org_id = grafana_organization.rk-private.org_id

  type = "cloudwatch-private"
  name = "cloudwatch"

  json_data_encoded = jsonencode({
    authType      = "default",
    defaultRegion = "ap-northeast-1",
    assumeRoleArn = aws_iam_role.grafana-private.arn,
  })
}
