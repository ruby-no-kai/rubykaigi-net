resource "aws_iam_role" "lambda" {
  name               = "LambdaAttendeeGate"
  description        = "rubykaigi-net//tf/attendee-gate"
  assume_role_policy = data.aws_iam_policy_document.lambda-trust.json
}

data "aws_iam_policy_document" "lambda-trust" {
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
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda" {
  role   = aws_iam_role.lambda.name
  policy = data.aws_iam_policy_document.lambda.json
}

data "aws_iam_policy_document" "lambda" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.attendee-gate.arn}/prd/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
    ]
    resources = [
      aws_ssm_parameter.hash-key.arn,
      aws_ssm_parameter.tito-api-token.arn,
    ]
  }
}
