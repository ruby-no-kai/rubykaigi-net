ephemeral "aws_ssm_parameter" "grafana-admin2" {
  arn        = aws_ssm_parameter.grafana-admin.arn
  depends_on = [helm_release.grafana]
}
provider "grafana" {
  url  = "https://grafana.rubykaigi.net/"
  auth = "admin:${ephemeral.aws_ssm_parameter.grafana-admin2.value}"
}

resource "grafana_organization" "rk-private" {
  name       = "RubyKaigi (ひみつだよ)"
  admin_user = "admin"
  depends_on = [helm_release.grafana, aws_security_group_rule.grafana-db_k8s-node]
}

resource "grafana_data_source" "prometheus" {
  type = "prometheus"
  name = "Prometheus"
  url  = "http://prometheus-operated.default.svc.cluster.local:9090"

  is_default = true
  depends_on = [helm_release.grafana, aws_security_group_rule.grafana-db_k8s-node]
}

resource "grafana_data_source" "alertmanager" {
  type = "alertmanager"
  name = "Alertmanager"
  url  = "http://alertmanager-operated.default.svc.cluster.local:9093"

  json_data_encoded = jsonencode({
    implementation = "prometheus",
  })

  depends_on = [helm_release.grafana, aws_security_group_rule.grafana-db_k8s-node]
}

resource "grafana_data_source" "cloudwatch" {
  type = "cloudwatch"
  name = "cloudwatch"

  json_data_encoded = jsonencode({
    authType      = "default",
    defaultRegion = "ap-northeast-1",
    assumeRoleArn = aws_iam_role.grafana-public.arn,
  })

  depends_on = [helm_release.grafana, aws_security_group_rule.grafana-db_k8s-node]
}

resource "grafana_data_source" "prometheus-private" {
  org_id = grafana_organization.rk-private.org_id

  type = "prometheus"
  name = "Prometheus"
  url  = "http://prometheus-operated.default.svc.cluster.local:9090"

  is_default = true

  depends_on = [helm_release.grafana, aws_security_group_rule.grafana-db_k8s-node]
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

  depends_on = [helm_release.grafana, aws_security_group_rule.grafana-db_k8s-node]
}
