data "aws_iam_policy" "NocAdminBase" {
  name = "NocAdminBase"
}

data "archive_file" "test_app" {
  type        = "zip"
  source_file = "${path.module}/test_app.rb"
  output_path = "${path.module}/test_app.zip"
}

resource "aws_lambda_function" "test-app" {
  function_name = "fnurl-utils-test-app"

  filename         = "${path.module}/test_app.zip"
  source_code_hash = data.archive_file.test_app.output_base64sha256
  handler          = "test_app.handler"

  runtime       = "ruby3.4"
  architectures = ["arm64"]
  layers = [
    aws_lambda_layer_version.function-url-utils["arm64 ruby3.4"].arn,
  ]

  role = aws_iam_role.test-app.arn

  memory_size = 128
  timeout     = 15

  environment {
    variables = {
      RACK_ENV = "production"
    }
  }
}

resource "aws_lambda_function_url" "test-app" {
  function_name      = aws_lambda_function.test-app.function_name
  authorization_type = "NONE"
}

resource "aws_iam_role" "test-app" {
  name                 = "LambdaFnurlTestApp"
  description          = "rubykaigi-net//tf/function-url-utils"
  assume_role_policy   = data.aws_iam_policy_document.test-app-trust.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

data "aws_iam_policy_document" "test-app-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda-AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.test-app.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

output "test_app_function_url" {
  value = aws_lambda_function_url.test-app.function_url
}
