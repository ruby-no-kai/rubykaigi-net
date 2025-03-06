resource "aws_lambda_function" "rack" {
  function_name = "attendee-gate-rack"

  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.attendee-gate.repository_url}:${local.app_ref}"
  architectures = ["arm64"]

  image_config {
    command = ["index.AttendeeGate::Handlers.http"]
  }

  role = aws_iam_role.lambda.arn

  memory_size = 128
  timeout     = 25

  environment {
    variables = merge({
    }, local.environment)
  }
}

resource "aws_lambda_function_url" "rack" {
  function_name      = aws_lambda_function.rack.function_name
  authorization_type = "NONE"
}

resource "aws_lambda_function" "generator" {
  function_name = "attendee-gate-generator"

  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.attendee-gate.repository_url}:${local.app_ref}"
  architectures = ["arm64"]

  image_config {
    command = ["index.AttendeeGate::Handlers.generate_data"]
  }

  role = aws_iam_role.lambda.arn

  memory_size = 256
  timeout     = 90

  environment {
    variables = merge({
    }, local.environment)
  }
}
output "api_url" {
  value = "${aws_lambda_function_url.rack.function_url}validate"
}
