resource "aws_iam_role" "LambdaGlazed" {
  name                 = "LambdaGlazed"
  description          = "rubykaigi-net//tf/glazed"
  assume_role_policy   = data.aws_iam_policy_document.LambdaGlazed-trust.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

data "aws_iam_policy_document" "LambdaGlazed-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role_policy_attachment" "LambdaGlazed-AWSLambdaVPCAccessExecutionRole" {
  role       = aws_iam_role.LambdaGlazed.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy" "LambdaGlazed" {
  role   = aws_iam_role.LambdaGlazed.name
  policy = data.aws_iam_policy_document.LambdaGlazed.json
}

data "aws_iam_policy_document" "LambdaGlazed" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      data.aws_s3_bucket.rk-infra.arn,
    ]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values   = ["${local.s3_prefix}*"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
    ]
    resources = [
      "${data.aws_s3_bucket.rk-infra.arn}/${local.s3_prefix}*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${data.aws_s3_bucket.rk-infra.arn}/${aws_s3_object.config.key}",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
    ]
    resources = concat(
      [
        aws_ssm_parameter.password.arn,
        aws_ssm_parameter.hmac-key.arn,
        aws_ssm_parameter.ssh-key.arn,
      ],
      [for p in aws_ssm_parameter.redact-pattern : p.arn],
    )
  }

  # Tells whether the execution holding the waiter record still runs
  statement {
    effect = "Allow"
    actions = [
      "states:DescribeExecution",
    ]
    resources = [
      "arn:aws:states:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:execution:glazed:*",
    ]
  }
}
