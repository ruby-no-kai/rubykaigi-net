resource "aws_lambda_function" "outbound" {
  function_name = "front-webhook-tweet-to-mastodon_outbound"

  filename         = "${path.module}/source.zip"
  source_code_hash = data.archive_file.source.output_base64sha256
  handler          = "outbound.handler"
  runtime          = "ruby2.7"
  architectures    = ["arm64"]

  role = aws_iam_role.function.arn

  memory_size = 128
  timeout     = 15

  environment {
    variables = local.env_vars
  }
}

resource "aws_lambda_event_source_mapping" "outbound_sqs" {
  event_source_arn = aws_sqs_queue.inbox.arn
  function_name    = aws_lambda_function.outbound.arn
}
