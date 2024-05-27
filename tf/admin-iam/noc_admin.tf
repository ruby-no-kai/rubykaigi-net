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
      values   = ["${data.aws_caller_identity.current.account_id}:NocAdmin:*"]
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
      "apprunner:*",
      "autoscaling:*",
      "chime:*",
      "cloudfront:*",
      "cloudwatch:*",
      "codebuild:*",
      "cognito-identity:*",
      "cognito-idp:*",
      "directconnect:*",
      "dynamodb:*",
      "ec2-instance-connect:*",
      "ec2:*",
      "ecr:*",
      "ecs:*",
      "eks:*",
      "elasticloadbalancing:*",
      "globalaccelerator:*",
      "iot:*",
      "ivs:*",
      "kms:*",    # XXX: too excessive
      "lambda:*", # XXX: too excessive
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

      "secretsmanager:*", # XXX: too excessive

      # IAMReadOnlyAccess
      "iam:GenerateCredentialReport",
      "iam:GenerateServiceLastAccessedDetails",
      "iam:Get*",
      "iam:List*",
      "iam:SimulateCustomPolicy",
      "iam:SimulatePrincipalPolicy",
      "iam:CreateServiceLinkedRole",

      # cost explorer,
      "ce:Get*",
      "ce:Describe*",
      "ce:CreateReport",
      "ce:DeleteReport",
      "ce:DeleteReport",
      "ce:CreateAnomalyMonitor",
      "ce:UpdateAnomalyMonitor",
      "ce:DeleteAnomalyMonitor",
      "ce:CreateAnomalySubscription",
      "ce:UpdateAnomalySubscription",
      "ce:DeleteAnomalySubscription",
      "savingsplans:Describe*",
      "aws-portal:View*",

      # resource explorer
      "resource-explorer-2:Get*",
      "resource-explorer-2:BatchGet*",
      "resource-explorer-2:List*",
      "resource-explorer-2:Search",
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
      "arn:aws:s3:::rubykaigi-public",
      "arn:aws:s3:::rubykaigi-public/*",
      "arn:aws:s3:::rk-tftp",
      "arn:aws:s3:::rk-tftp/*",
      "arn:aws:s3:::signage-dev-pub",
      "arn:aws:s3:::signage-dev-pub/*",
      "arn:aws:s3:::signage-prd-pub",
      "arn:aws:s3:::signage-prd-pub/*",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole", "sts:TagSession"]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TakeoutUser",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TakeoutUserDev",
    ]
  }

  statement {
    effect  = "Deny"
    actions = ["*"]
    resources = [
      "arn:aws:dynamodb:ap-northeast-1:005216166247:table/himari-prd",
      "arn:aws:dynamodb:ap-northeast-1:005216166247:table/himari-prd/*",
      "arn:aws:secretsmanager:ap-northeast-1:005216166247:secret:himari-prd-*",
      "arn:aws:cloudfront::005216166247:distribution/E28V10WV08LDV0",
      "arn:aws:iam::005216166247:role/LambdaHimari",
      "arn:aws:iam::005216166247:role/LambdaAmc",
      "arn:aws:secretsmanager:ap-northeast-1:005216166247:secret:amc/*",
      "arn:aws:cloudfront::005216166247:distribution/E1WQVN1OCCTP56",
      "arn:aws:lambda:ap-northeast-1:005216166247:function:amc-*",
      "arn:aws:lambda:ap-northeast-1:005216166247:function:himari-prd-*",
      "arn:aws:ecr:ap-northeast-1:005216166247:repository/himari-*",
    ]
  }
  statement {
    effect      = "Deny"
    not_actions = ["iam:Get*"]
    resources = [
      "arn:aws:iam::005216166247:role/FederatedAdmin",
      "arn:aws:iam::005216166247:role/OrgzAdmin",
      "arn:aws:iam::005216166247:role/KaigiStaff",
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
}
