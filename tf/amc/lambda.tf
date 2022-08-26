data "archive_file" "amc" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/amc.zip"

  depends_on = [
    null_resource.amc-bundle-install,
    null_resource.amc-tsc,
    null_resource.amc-revision,
  ]
}

locals {
  tsdgst   = sha256(join("", [for f in fileset("${path.module}/src", "public/**/*.ts") : filesha256("${path.module}/src/${f}")]))
  rbdgst   = sha256(join("", [for f in fileset("${path.module}/src", "public/**/*.rb") : filesha256("${path.module}/src/${f}")]))
  lockdgst = filesha256("${path.module}/src/Gemfile.lock")
}

resource "null_resource" "amc-bundle-install" {
  triggers = {
    lockdgst = local.lockdgst
  }
  provisioner "local-exec" {
    command = "cd ${path.module}/src && bundle config set path vendor/bundle && BUNDLE_DEPLOYMENT=1 RBENV_VERSION=2.7 bundle install"
  }
}
resource "null_resource" "amc-tsc" {
  triggers = {
    tsdgst = local.tsdgst
  }
  provisioner "local-exec" {
    command = "cd ${path.module}/src && tsc -b"
  }
}

resource "null_resource" "amc-revision" {
  triggers = {
    tsdgst   = local.tsdgst,
    rbdgst   = local.rbdgst,
    lockdgst = local.lockdgst
  }
  provisioner "local-exec" {
    command = "cd ${path.module}/src && echo 'unknown.${sha256("${local.tsdgst}${local.rbdgst}${local.lockdgst}")}' > REVISION"
  }
}

resource "aws_lambda_function" "amc" {
  function_name = "rknw-amc"

  filename         = "${path.module}/amc.zip"
  source_code_hash = data.archive_file.amc.output_base64sha256
  handler          = "app.handler"
  runtime          = "ruby2.7"
  architectures    = ["arm64"]

  role = aws_iam_role.amc.arn

  memory_size = 128
  timeout     = 15

  environment {
    variables = {
      AMC_EXPECT_ISS       = "https://idp.rubykaigi.net"
      AMC_SELF_ISS         = "https://amc.rubykaigi.net"
      AMC_PROVIDER_ID      = "amc.rubykaigi.net"
      AMC_ROLE_ARN         = data.aws_iam_role.nocadmin.arn
      AMC_SIGNING_KEY_ARN  = aws_secretsmanager_secret.signing_key.arn
      AMC_SESSION_DURATION = tostring(3600 * 12)
    }
  }
}

# refer to core/ tfstate for target groups

