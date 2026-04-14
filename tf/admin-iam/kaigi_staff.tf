resource "aws_iam_role" "KaigiStaff" {
  name                 = "KaigiStaff"
  description          = "rubykaigi-nw:tf/admin-iam aws_iam_role.KaigiStaff"
  assume_role_policy   = data.aws_iam_policy_document.KaigiStaff-trust.json
  max_session_duration = 3600 * 12
}

data "aws_iam_policy_document" "KaigiStaff-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
      ]
    }
  }
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity", "sts:TagSession"]
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/amc.rubykaigi.net",
      ]
    }
    condition {
      test     = "StringLike"
      variable = "amc.rubykaigi.net:sub"
      values   = ["${data.aws_caller_identity.current.account_id}:KaigiStaff:*"]
    }
  }
}

resource "aws_iam_role_policy" "KaigiStaff_KaigiStaff" {
  role   = aws_iam_role.KaigiStaff.name
  policy = data.aws_iam_policy_document.KaigiStaff.json
}

resource "aws_iam_role_policy" "KaigiStaff_StreamingStaff" {
  role   = aws_iam_role.KaigiStaff.name
  policy = data.aws_iam_policy_document.StreamingStaff.json
}

resource "aws_iam_role_policy_attachment" "KaigiStaff_AWSManagementConsoleBasicUserAccess" {
  role       = aws_iam_role.KaigiStaff.name
  policy_arn = data.aws_iam_policy.AWSManagementConsoleBasicUserAccess.arn
}

data "aws_iam_policy_document" "KaigiStaff" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListAllMyBuckets",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "s3:Get*"
    ]
    resources = ["arn:aws:s3:::rubykaigi-public", "arn:aws:s3:::rubykaigi-public/*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "cloudfront:ListDistribution",
      "cloudfront:ListDistribution*",
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "cloudfront:GetDistribution*",
      "cloudfront:GetInvalidation*",
      "cloudfront:CreateInvalidation*",
      "cloudfront:Update*",
    ]
    resources = [
      "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/E2WEWQCYU12GVD", # rubykaigi.org (rko-router)
      "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/E3FY4LG7LBB19V", # storage.rubykaigi.org
    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole", "sts:TagSession"]
    resources = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/SignageDeveloper"]
  }
}
