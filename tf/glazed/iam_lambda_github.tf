# Trusted by .github/sts-cat/glazed.sts.toml
resource "aws_iam_role" "LambdaGlazedGithub" {
  name                 = "LambdaGlazedGithub"
  description          = "rubykaigi-net//tf/glazed"
  assume_role_policy   = data.aws_iam_policy_document.LambdaGlazed-trust.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

resource "aws_iam_role_policy_attachment" "LambdaGlazedGithub-AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.LambdaGlazedGithub.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "LambdaGlazedGithub" {
  role   = aws_iam_role.LambdaGlazedGithub.name
  policy = data.aws_iam_policy_document.LambdaGlazedGithub.json
}

data "aws_iam_policy_document" "LambdaGlazedGithub" {
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
    ]
    resources = [
      "${data.aws_s3_bucket.rk-infra.arn}/${local.s3_prefix}*",
      "${data.aws_s3_bucket.rk-infra.arn}/${aws_s3_object.config.key}",
    ]
  }

  # Exchanged for a GitHub token at tf/sts-cat
  statement {
    effect = "Allow"
    actions = [
      "sts:GetWebIdentityToken",
    ]
    resources = ["*"]
    condition {
      test     = "ForAllValues:StringEquals"
      variable = "sts:IdentityTokenAudience"
      values   = ["https://sts-cat.rubykaigi.net"]
    }
  }
}
