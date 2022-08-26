resource "aws_iam_role" "amc" {
  name               = "NwLambdaAmc"
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

resource "aws_iam_role_policy" "amc" {
  role   = aws_iam_role.amc.name
  policy = data.aws_iam_policy_document.amc.json
}

data "aws_iam_policy_document" "amc" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecretVersionStage",
      "secretsmanager:DescribeSecret"
    ]
    resources = [aws_secretsmanager_secret.signing_key.arn]
  }
}

data "aws_iam_role" "nocadmin" {
  name = "NocAdmin"
}
