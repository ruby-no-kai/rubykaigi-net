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
  }
}

resource "aws_iam_policy" "nocadmin-base" {
  name        = "NocAdminBase"
  description = "attached to NocAdmin and used for boundary"
  policy      = data.aws_iam_policy_document.nocadmin.json
}

resource "aws_iam_role_policy_attachment" "nocadmin-base" {
  role       = aws_iam_role.NocAdmin.name
  policy_arn = aws_iam_policy.nocadmin-base.arn
}

data "aws_iam_policy_document" "nocadmin" {
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

      "s3:ListMyBuckets",
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
    ]
  }
}

resource "aws_iam_role_policy" "nocadmin-iam-with-boundary" {
  role   = aws_iam_role.NocAdmin.name
  policy = data.aws_iam_policy_document.nocadmin-iam-with-boundary.json
}

data "aws_iam_policy_document" "nocadmin-iam-with-boundary" {
  statement {
    actions = [
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
      "iam:Untag*",
    ]

    resources = ["*"]
  }

  statement {
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreateRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
    ]

    resources = ["*"]

    condition {
      test     = "ArnEquals"
      variable = "iam:PermissionsBoundary"

      values = [aws_iam_policy.nocadmin-base.arn]
    }
  }
}
