resource "aws_iam_role" "SignageDeveloper" {
  name                 = "SignageDeveloper"
  description          = "signage-app developer (shared dev/prd)"
  assume_role_policy   = data.aws_iam_policy_document.SignageDeveloper-trust.json
  max_session_duration = 43200
}

data "aws_iam_policy_document" "SignageDeveloper-trust" {
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
      values   = ["${data.aws_caller_identity.current.account_id}:SignageDeveloper:*"]
    }
  }
}

resource "aws_iam_role_policy" "SignageDeveloper" {
  role   = aws_iam_role.SignageDeveloper.name
  policy = data.aws_iam_policy_document.SignageDeveloper.json
}

data "aws_iam_policy_document" "SignageDeveloper" {
  statement {
    effect = "Allow"
    actions = [
      "transcribe:StartStreamTranscription*",
      "transcribe:StartStreamTranscriptionWebSocket",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "sts:GetServiceBearerToken",
    ]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = ["dynamodb:*"]
    resources = [
      "arn:aws:dynamodb:ap-northeast-1:${data.aws_caller_identity.current.account_id}:table/signage-dev",
      "arn:aws:dynamodb:ap-northeast-1:${data.aws_caller_identity.current.account_id}:table/signage-dev/index/inverted",
      "arn:aws:dynamodb:ap-northeast-1:${data.aws_caller_identity.current.account_id}:table/signage-prd",
      "arn:aws:dynamodb:ap-northeast-1:${data.aws_caller_identity.current.account_id}:table/signage-prd/index/inverted",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["secretsmanager:GetSecretValue"]
    resources = [
      "arn:aws:secretsmanager:ap-northeast-1:${data.aws_caller_identity.current.account_id}:secret:signage-dev/discord-*",
      "arn:aws:secretsmanager:ap-northeast-1:${data.aws_caller_identity.current.account_id}:secret:signage-prd/discord-*",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["ssm:GetParameters"]
    resources = [
      "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/signage/dev/*",
      "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/signage/prd/*",
    ]
  }

  statement {
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = [data.aws_kms_key.ssm.arn]
  }

  statement {
    effect  = "Allow"
    actions = ["iot:Connect"]
    resources = [
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:client/signage-dev-*",
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:client/signage-prd-*",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["iot:Publish"]
    resources = [
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:topic/signage-dev/uplink/*",
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:topic/signage-prd/uplink/*",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["iot:Subscribe"]
    resources = [
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:topicfilter/signage-dev/uplink/*",
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:topicfilter/signage-dev/downlink/*",
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:topicfilter/signage-prd/uplink/*",
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:topicfilter/signage-prd/downlink/*",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["iot:Receive"]
    resources = [
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:topic/signage-dev/uplink/*",
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:topic/signage-dev/downlink/*",
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:topic/signage-prd/uplink/*",
      "arn:aws:iot:ap-northeast-1:${data.aws_caller_identity.current.account_id}:topic/signage-prd/downlink/*",
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
      "arn:aws:s3:::signage-dev-pub/dynamic/*",
      "arn:aws:s3:::signage-prd-pub/dynamic/*",
    ]
  }

}

data "aws_kms_key" "ssm" {
  key_id = "alias/aws/ssm"
}
