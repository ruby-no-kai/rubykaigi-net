ephemeral "aws_secretsmanager_secret_version" "rds-root" {
  secret_id = aws_rds_cluster.grafana.master_user_secret[0].secret_arn
}


ephemeral "random_password" "rds-grafana" {
  length  = 48
  special = false
}
resource "aws_ssm_parameter" "rds-grafana" {
  name             = "/rds/grafana/grafana"
  type             = "SecureString"
  value_wo         = ephemeral.random_password.rds-grafana.result
  value_wo_version = 2
}
ephemeral "aws_ssm_parameter" "rds-grafana" {
  arn = aws_ssm_parameter.rds-grafana.arn
}
resource "kubernetes_secret_v1" "grafana-mysql" {
  metadata {
    namespace = "default"
    name      = "grafana-mysql"
  }
  data_wo_revision = 1
  data_wo = {
    "username" = "grafana"
    "password" = ephemeral.aws_ssm_parameter.rds-grafana.value
  }

  depends_on = [null_resource.rds-provision]
}

resource "null_resource" "rds-provision" {
  triggers = {
    rds_cluster_id = aws_rds_cluster.grafana.id
    epoch          = 3
  }
  provisioner "local-exec" {
    command = "ruby provision.rb"
    environment = {
      RDS_HOST        = aws_rds_cluster.grafana.endpoint
      RDS_PORT        = aws_rds_cluster.grafana.port
      RDS_USER        = "root"
      RDS_PASSWORD    = jsondecode(ephemeral.aws_secretsmanager_secret_version.rds-root.secret_string).password
      TARGET_PASSWORD = ephemeral.aws_ssm_parameter.rds-grafana.value
    }
  }

  depends_on = [aws_rds_cluster_instance.grafana-001]
}
