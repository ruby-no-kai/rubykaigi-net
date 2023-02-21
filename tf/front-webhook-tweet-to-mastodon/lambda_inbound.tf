resource "aws_lambda_function" "inbound" {
  function_name = "front-webhook-tweet-to-mastodon_inbound"

  filename         = "${path.module}/source.zip"
  source_code_hash = data.archive_file.source.output_base64sha256
  handler          = "inbound.handler"
  runtime          = "ruby2.7"
  architectures    = ["arm64"]

  role = aws_iam_role.function.arn

  memory_size = 128
  timeout     = 15

  environment {
    variables = local.env_vars
  }
}

resource "aws_lambda_function_url" "inbound" {
  function_name      = aws_lambda_function.inbound.function_name
  authorization_type = "NONE"
}
