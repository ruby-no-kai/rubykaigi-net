data "aws_iam_openid_connect_provider" "github-actions" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "GhaRkoPreview" {
  name                 = "GhaRkoPreview"
  assume_role_policy   = data.aws_iam_policy_document.GhaRkoPreview-trust.json
  max_session_duration = 3600 * 4
}

data "aws_iam_policy_document" "GhaRkoPreview-trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github-actions.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:ruby-no-kai/rubykaigi.org:pull_request",
        "repo:ruby-no-kai/rubykaigi.org:environment:preview",
      ]
    }
  }

}

resource "aws_iam_role_policy" "GhaRkoPreview" {
  role   = aws_iam_role.GhaRkoPreview.id
  name   = "GhaRkoPreview"
  policy = data.aws_iam_policy_document.GhaRkoPreview.json
}

data "aws_iam_policy_document" "GhaRkoPreview" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.rko-preview.arn,
      "${aws_s3_bucket.rko-preview.arn}/pr-*",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation",
    ]
    resources = [
      aws_cloudfront_distribution.rko-preview.arn,
    ]
  }
}
