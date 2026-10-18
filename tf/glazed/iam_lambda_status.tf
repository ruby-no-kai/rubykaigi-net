resource "aws_iam_role" "LambdaGlazedStatusReader" {
  name                 = "LambdaGlazedStatusReader"
  description          = "rubykaigi-net//tf/glazed"
  assume_role_policy   = data.aws_iam_policy_document.LambdaGlazed-trust.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

resource "aws_iam_role_policy_attachment" "LambdaGlazedStatusReader-AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.LambdaGlazedStatusReader.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "LambdaGlazedStatusReader" {
  role   = aws_iam_role.LambdaGlazedStatusReader.name
  policy = data.aws_iam_policy_document.LambdaGlazedStatusReader.json
}

# Read only: the state is fetched but never uploaded
data "aws_iam_policy_document" "LambdaGlazedStatusReader" {
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
    ]
    resources = [
      "${data.aws_s3_bucket.rk-infra.arn}/${local.state_key}",
      "${data.aws_s3_bucket.rk-infra.arn}/${aws_s3_object.config.key}",
    ]
  }
}

resource "aws_iam_role" "LambdaGlazedStatus" {
  name                 = "LambdaGlazedStatus"
  description          = "rubykaigi-net//tf/glazed"
  assume_role_policy   = data.aws_iam_policy_document.LambdaGlazed-trust.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

resource "aws_iam_role_policy_attachment" "LambdaGlazedStatus-AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.LambdaGlazedStatus.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "LambdaGlazedStatus" {
  role   = aws_iam_role.LambdaGlazedStatus.name
  policy = data.aws_iam_policy_document.LambdaGlazedStatus.json
}

data "aws_iam_policy_document" "LambdaGlazedStatus" {
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      aws_lambda_function.glazed-status-reader.arn,
      "${aws_lambda_function.glazed-status-reader.arn}:*",
    ]
  }

  # HeadObject on the state to compare the version
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${data.aws_s3_bucket.rk-infra.arn}/${local.state_key}",
    ]
  }

  # Without s3:ListBucket, HeadObject answers 403 instead of 404 for a page not published yet
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      data.aws_s3_bucket.rubykaigi-dot-net.arn,
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      "${data.aws_s3_bucket.rubykaigi-dot-net.arn}/${local.status_output_key}",
    ]
  }
}
