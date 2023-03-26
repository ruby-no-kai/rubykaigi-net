resource "aws_iam_role" "NocAdmin" {
  name                 = "NocAdmin"
  description          = "rubykaigi-nw aws_iam_role.NocAdmin"
  assume_role_policy   = data.aws_iam_policy_document.NocAdmin-trust.json
  max_session_duration = 3600 * 12
}

data "aws_iam_policy_document" "NocAdmin-trust" {
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
      values   = ["NocAdmin:*"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "NocAdmin_NocAdminBase" {
  role       = aws_iam_role.NocAdmin.name
  policy_arn = aws_iam_policy.NocAdminBase.arn
}

resource "aws_iam_policy" "NocAdminBase" {
  name        = "NocAdminBase"
  description = "attached to NocAdmin and used for boundary"
  policy      = data.aws_iam_policy_document.NocAdminBase.json
}

data "aws_iam_policy_document" "NocAdminBase" {
  statement {
    effect = "Allow"
    actions = [
      "acm:*",
      "apigateway:*",
      "application-autoscaling:*",
      "autoscaling:*",
      "chime:*",
      "cloudfront:*",
      "cloudwatch:*",
      "codebuild:*",
      "directconnect:*",
      "dynamodb:*",
      "ec2-instance-connect:*",
      "ec2:*",
      "ecr:*",
      "ecs:*",
      "eks:*",
      "elasticloadbalancing:*",
      "globalaccelerator:*",
      "ivs:*",
      "kms:*", # XXX: too excessive
      "lambda:*",
      "logs:*",
      "medialive:*",
      "rds:*",
      "route53:*",
      "ssm:*",
      "transcribe:*",

      # k8s load-balancer-controller
      "cognito-idp:*",
      "waf-regional:*",
      "wafv2:*",
      "shield:*",

      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",

      # IAMReadOnlyAccess
      "iam:GenerateCredentialReport",
      "iam:GenerateServiceLastAccessedDetails",
      "iam:Get*",
      "iam:List*",
      "iam:SimulateCustomPolicy",
      "iam:SimulatePrincipalPolicy",
      "iam:CreateServiceLinkedRole",
    ]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:*"]
    resources = [
      "arn:aws:s3:::rk-infra",
      "arn:aws:s3:::rk-infra/*",
      "arn:aws:s3:::rk-aws-logs",
      "arn:aws:s3:::rk-aws-logs/*",
      "arn:aws:s3:::rk-syslog",
      "arn:aws:s3:::rk-syslog/*",
      "arn:aws:s3:::rk-takeout-app",
      "arn:aws:s3:::rk-takeout-app/*",
      "arn:aws:s3:::am-i-not-at-rubykaigi",
      "arn:aws:s3:::am-i-not-at-rubykaigi/*",
    ]
  }
}

resource "aws_iam_role_policy" "NocAdmin_iam-with-boundary" {
  role   = aws_iam_role.NocAdmin.name
  policy = data.aws_iam_policy_document.NocAdmin_iam-with-boundary.json
}

data "aws_iam_policy_document" "NocAdmin_iam-with-boundary" {
  statement {
    effect = "Allow"
    actions = [
      "iam:AddRoleToInstanceProfile",
      "iam:CreateInstanceProfile",
      "iam:CreateOpenIDConnectProvider",
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:CreateServiceLinkedRole",
      "iam:CreateServiceSpecificCredential",
      "iam:DeleteInstanceProfile",
      "iam:DeletePolicyVersion",
      "iam:GenerateOrganizationsAccessReport",
      "iam:GenerateServiceLastAccessedDetails",
      "iam:PassRole",
      "iam:RemoveRoleFromInstanceProfile",
      "iam:SetDefaultPolicyVersion",
      "iam:SetSecurityTokenServicePreferences",
      "iam:Simulate*",
      "iam:Tag*",
      "iam:UpdateAssumeRolePolicy",
      "iam:Untag*",
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePermissionsBoundary",
      "iam:PutRolePolicy",
    ]

    resources = ["*"]

    condition {
      test     = "ArnEquals"
      variable = "iam:PermissionsBoundary"

      values = [aws_iam_policy.NocAdminBase.arn]
    }
  }

  statement {
    effect  = "Deny"
    actions = ["*"]
    resources = [
      "arn:aws:iam::005216166247:role/FederatedAdmin",
      "arn:aws:iam::005216166247:role/OrgzAdmin",
      "arn:aws:iam::005216166247:role/KaigiStaff",
    ]
  }
}
