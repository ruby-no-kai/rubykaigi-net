ephemeral "random_password" "hash-key" {
  length = 64
}
resource "aws_ssm_parameter" "hash-key" {
  name             = "${local.environment.SSM_PREFIX}HASH_KEY"
  type             = "SecureString"
  value_wo         = ephemeral.random_password.hash-key.result
  value_wo_version = 1
}

resource "aws_ssm_parameter" "tito-api-token" {
  name             = "${local.environment.SSM_PREFIX}TITO_API_TOKEN"
  type             = "SecureString"
  value_wo         = "dummy"
  value_wo_version = 1
}
