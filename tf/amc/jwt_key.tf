# private key to generate JWT

resource "aws_secretsmanager_secret" "signing_key" {
  name = "amc/signing-key"
}

resource "aws_secretsmanager_secret_rotation" "signing_key" {
  secret_id           = aws_secretsmanager_secret.signing_key.id
  rotation_lambda_arn = aws_lambda_function.signing_key_rotation.arn

  rotation_rules {
    automatically_after_days = 2
  }

  depends_on = [
    aws_iam_role_policy.amc-signingkey,
    aws_lambda_permission.signing_key_rotation,
  ]
}

resource "aws_lambda_function" "signing_key_rotation" {
  function_name = "amc-keyrotation"

  filename         = "${path.module}/amc.zip"
  source_code_hash = data.archive_file.amc.output_base64sha256
  handler          = "key_rotation.handler"
  runtime          = "ruby2.7"
  architectures    = ["arm64"]

  role = aws_iam_role.amc.arn

  memory_size = 128
  timeout     = 15
}

resource "aws_lambda_permission" "signing_key_rotation" {
  statement_id   = "secretsmanager"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.signing_key_rotation.function_name
  principal      = "secretsmanager.amazonaws.com"
  source_account = data.aws_caller_identity.current.account_id
}
