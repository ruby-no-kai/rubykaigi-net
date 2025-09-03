ephemeral "aws_secretsmanager_secret_version" "rds-root" {
  secret_id = aws_rds_cluster.kea.master_user_secret[0].secret_arn
}



ephemeral "random_password" "rds-kea" {
  length  = 48
  special = false
}
resource "aws_ssm_parameter" "rds-kea" {
  name             = "/rds/kea/kea"
  type             = "SecureString"
  value_wo         = ephemeral.random_password.rds-kea.result
  value_wo_version = 2
}
ephemeral "aws_ssm_parameter" "rds-kea" {
  arn = aws_ssm_parameter.rds-kea.arn
}
resource "kubernetes_secret_v1" "kea-mysql" {
  metadata {
    namespace = "default"
    name      = "kea-mysql"
  }
  data_wo_revision = 2
  data_wo = {
    "username" = "kea"
    "password" = ephemeral.aws_ssm_parameter.rds-kea.value
  }

  depends_on = [null_resource.rds-provision]
}


resource "null_resource" "rds-provision" {
  triggers = {
    rds_cluster_id = aws_rds_cluster.kea.id
    epoch          = 3
  }
  provisioner "local-exec" {
    command = "ruby provision.rb"
    environment = {
      RDS_HOST        = aws_rds_cluster.kea.endpoint
      RDS_PORT        = aws_rds_cluster.kea.port
      RDS_USER        = "root"
      RDS_PASSWORD    = jsondecode(ephemeral.aws_secretsmanager_secret_version.rds-root.secret_string).password
      TARGET_PASSWORD = ephemeral.aws_ssm_parameter.rds-kea.value
    }
  }

  depends_on = [aws_rds_cluster_instance.kea-001]
}
