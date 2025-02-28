data "archive_file" "source" {
  type        = "zip"
  source_file = "${path.module}/function.rb"
  output_path = "${path.module}/source.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name = "tfstate-monitor"

  filename         = "${path.module}/source.zip"
  source_code_hash = data.archive_file.source.output_base64sha256
  handler          = "function.handler"
  runtime          = "ruby3.3"
  architectures    = ["arm64"]

  role = aws_iam_role.function.arn

  memory_size = 128
  timeout     = 60

  environment {
    variables = {
      S3_BUCKET        = data.aws_s3_bucket.rk-infra.bucket
      S3_PREFIX        = "terraform/"
      OUTPUT_S3_BUCKET = "rubykaigi-dot-net"
      OUTPUT_S3_KEY    = "tfstate-monitor"
    }
  }
}
