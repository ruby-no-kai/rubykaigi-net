resource "aws_iam_role" "function" {
  name                 = "LambdaTfstateMonitor"
  description          = "rubykaigi-nw tf/tfstate-monitor"
  assume_role_policy   = data.aws_iam_policy_document.function-trust.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

data "aws_iam_policy_document" "function-trust" {
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

resource "aws_iam_role_policy_attachment" "function-AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.function.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "function" {
  role   = aws_iam_role.function.name
  policy = data.aws_iam_policy_document.function.json
}

data "aws_iam_policy_document" "function" {
  statement {
    effect = "Allow"
    actions = [
      "ce:GetCostAndUsage",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]
    resources = [
      data.aws_s3_bucket.rk-infra.arn,
      "${data.aws_s3_bucket.rk-infra.arn}/terraform/*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "arn:aws:s3:::rubykaigi-dot-net/tfstate-monitor",
    ]
  }
}
