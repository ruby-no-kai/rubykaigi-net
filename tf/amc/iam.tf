resource "aws_iam_role" "amc" {
  name               = "LambdaAmc"
  description        = "rubykaigi-nw tf/amc aws_iam_role.amc"
  assume_role_policy = data.aws_iam_policy_document.amc-trust.json
}

data "aws_iam_policy_document" "amc-trust" {
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

resource "aws_iam_role_policy_attachment" "amc-AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.amc.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "amc-signingkey" {
  role   = aws_iam_role.amc.name
  policy = data.aws_iam_policy_document.amc-signingkey.json
}

data "aws_iam_policy_document" "amc-signingkey" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [
      aws_secretsmanager_secret.signing_key.arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:UpdateSecretVersionStage",
      "secretsmanager:PutSecretValue",
    ]
    resources = [
      aws_secretsmanager_secret.signing_key.arn,
    ]
    condition {
      test     = "StringEquals"
      variable = "lambda:SourceFunctionArn"
      values   = [aws_lambda_function.signing_key_rotation.arn]
    }
  }
}

resource "aws_iam_role_policy" "amc-params" {
  role   = aws_iam_role.amc.name
  policy = data.aws_iam_policy_document.amc-params.json
}

data "aws_iam_policy_document" "amc-params" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [
      aws_secretsmanager_secret.params.arn,
    ]
  }
}
