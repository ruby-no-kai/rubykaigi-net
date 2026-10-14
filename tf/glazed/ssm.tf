# Some devices accept passwords of up to 24 characters.
ephemeral "random_password" "password" {
  length  = 24
  special = false
}

# glazed reads hmac_key as base64; 44 alphanumerics are valid base64 of 33 bytes.
ephemeral "random_password" "hmac-key" {
  length  = 44
  special = false
}

resource "aws_ssm_parameter" "password" {
  name             = "/glazed/prd/password"
  type             = "SecureString"
  value_wo         = ephemeral.random_password.password.result
  value_wo_version = 1
}

# Keep it stable: a new key changes every digest of the redacted configurations at once.
resource "aws_ssm_parameter" "hmac-key" {
  name             = "/glazed/prd/hmac-key"
  type             = "SecureString"
  value_wo         = ephemeral.random_password.hmac-key.result
  value_wo_version = 1
}

# Set the private key with `aws ssm put-parameter --overwrite`.
resource "aws_ssm_parameter" "ssh-key" {
  name             = "/glazed/prd/ssh-key"
  type             = "SecureString"
  value_wo         = "dummy"
  value_wo_version = 1
}

# Regular expressions of values to hide from redacted configurations, kept out of this repository.
# Set each with `aws ssm put-parameter --overwrite`.
resource "aws_ssm_parameter" "redact-pattern" {
  for_each = toset([
    "nrt-ngnx",
    "nrt-ngnn",
    "hnd-ngnx",
    "hnd-ngnn",
    "itm-ngn",
    "hnd-uplink",
  ])

  name             = "/glazed/prd/redact-pattern/${each.key}"
  type             = "String"
  value_wo         = "dummy"
  value_wo_version = 1
}
