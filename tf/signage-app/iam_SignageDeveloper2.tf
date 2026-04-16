resource "aws_iam_role" "SignageDeveloper2" {
  name                 = "SignageDeveloper2"
  description          = "signage-app developer (shared dev/prd)"
  assume_role_policy   = data.aws_iam_policy_document.SignageDeveloper2-trust.json
  max_session_duration = 43200
}

data "aws_iam_policy_document" "SignageDeveloper2-trust" {
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
      values   = ["${data.aws_caller_identity.current.account_id}:SignageDeveloper2:*"]
    }
  }
}

resource "aws_iam_role_policy" "SignageDeveloper2" {
  role   = aws_iam_role.SignageDeveloper2.name
  policy = data.aws_iam_policy_document.SignageDeveloper2.json
}

data "aws_iam_policy_document" "SignageDeveloper2" {
  statement {
    effect  = "Allow"
    actions = ["dynamodb:*"]
    resources = [
      "arn:aws:dynamodb:ap-northeast-1:${data.aws_caller_identity.current.account_id}:table/signage-dev",
      "arn:aws:dynamodb:ap-northeast-1:${data.aws_caller_identity.current.account_id}:table/signage-dev/index/inverted",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["iot:Connect"]
    resources = [
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:client/signage-dev-*",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["iot:Publish"]
    resources = [
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:topic/signage-dev/uplink/*",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["iot:Subscribe"]
    resources = [
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:topicfilter/signage-dev/uplink/*",
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:topicfilter/signage-dev/downlink/*",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["iot:Receive"]
    resources = [
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:topic/signage-dev/uplink/*",
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:topic/signage-dev/downlink/*",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:ListBucket", "s3:GetBucketLocation"]
    resources = [
      "arn:aws:s3:::signage-dev-pub",
      "arn:aws:s3:::signage-dev-pub/*",
      "arn:aws:s3:::signage-prd-pub",
      "arn:aws:s3:::signage-prd-pub/*",
    ]
  }
  statement {
    effect  = "Allow"
    actions = ["s3:ListAllMyBuckets"]
    resources = [
      "*"
    ]
  }
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = [
      "arn:aws:s3:::signage-dev-pub/dynamic/data/photos/*",
      "arn:aws:s3:::signage-prd-pub/dynamic/data/photos/*",
    ]
  }
}
