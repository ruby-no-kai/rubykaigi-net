locals {
  # Key of the sqlite state in rk-infra: the state storage prefix and the orchestrator's state key
  state_key = "glazed/state/state.sqlite3"

  status_output_key = "glazed"
}

data "aws_s3_bucket" "rubykaigi-dot-net" {
  bucket = "rubykaigi-dot-net"
}

# Reads the state, as `glazed status --json` does. Outside the VPC; it reaches no device.
resource "aws_lambda_function" "glazed-status-reader" {
  function_name = "glazed-status-reader"

  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.glazed-lambda.repository_url}:${local.image_tag}"
  architectures = ["x86_64"]
  publish       = true

  role = aws_iam_role.LambdaGlazedStatusReader.arn

  memory_size = 512
  timeout     = 60

  environment {
    variables = {
      GLAZED_CONFIG_S3_BUCKET = aws_s3_object.config.bucket
      GLAZED_CONFIG_S3_KEY    = aws_s3_object.config.key
      GLAZED_CONFIG_S3_DIGEST = filebase64sha256(local.config_path)
    }
  }

  depends_on = [
    aws_ecr_repository_policy.glazed-lambda,
    aws_lambda_invocation.skopeo-copy-glazed-lambda,
    aws_iam_role_policy.LambdaGlazedStatusReader,
    aws_iam_role_policy_attachment.LambdaGlazedStatusReader-AWSLambdaBasicExecutionRole,
  ]
}

data "archive_file" "glazed-status" {
  type        = "zip"
  source_file = "${path.module}/status_function.rb"
  output_path = "${path.module}/status_function.zip"
}

# Renders the state to https://rubykaigi.net/glazed
resource "aws_lambda_function" "glazed-status" {
  function_name = "glazed-status"

  filename         = data.archive_file.glazed-status.output_path
  source_code_hash = data.archive_file.glazed-status.output_base64sha256
  handler          = "status_function.handler"
  runtime          = "ruby3.4"
  architectures    = ["arm64"]

  role = aws_iam_role.LambdaGlazedStatus.arn

  memory_size = 128
  timeout     = 120

  environment {
    variables = {
      READER_FUNCTION  = aws_lambda_function.glazed-status-reader.function_name
      STATE_S3_BUCKET  = data.aws_s3_bucket.rk-infra.bucket
      STATE_S3_KEY     = local.state_key
      OUTPUT_S3_BUCKET = data.aws_s3_bucket.rubykaigi-dot-net.bucket
      OUTPUT_S3_KEY    = local.status_output_key
    }
  }

  depends_on = [
    aws_iam_role_policy.LambdaGlazedStatus,
    aws_iam_role_policy_attachment.LambdaGlazedStatus-AWSLambdaBasicExecutionRole,
  ]
}

# Every write of the state, which happens on each lease and completion of a run
resource "aws_cloudwatch_event_rule" "glazed-status" {
  name = "glazed-status"
  event_pattern = jsonencode({
    source      = ["aws.s3"],
    detail-type = ["Object Created"],
    detail = {
      bucket = {
        name = [data.aws_s3_bucket.rk-infra.bucket],
      }
      object = {
        key = [local.state_key],
      }
    },
  })
}

resource "aws_cloudwatch_event_target" "glazed-status" {
  rule      = aws_cloudwatch_event_rule.glazed-status.name
  target_id = "glazed-status"
  arn       = aws_lambda_function.glazed-status.arn

  retry_policy {
    maximum_retry_attempts       = 2
    maximum_event_age_in_seconds = 300
  }
}

resource "aws_lambda_permission" "glazed-status-events" {
  statement_id  = "AllowEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.glazed-status.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.glazed-status.arn
}

# Renews the snapshot time shown on the page, and recovers from a lost event
resource "aws_scheduler_schedule" "glazed-status" {
  name = "glazed-status"

  flexible_time_window {
    mode = "OFF"
  }
  schedule_expression = "rate(15 minutes)"

  target {
    arn      = aws_lambda_function.glazed-status.arn
    role_arn = aws_iam_role.EventsGlazed.arn
    input    = jsonencode({})
  }
}
