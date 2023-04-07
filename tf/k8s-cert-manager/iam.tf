data "aws_iam_policy" "nocadmin-base" {
  name = "NocAdminBase"
}

resource "aws_iam_role" "cert-manager" {
  name                 = "NwCertManager"
  description          = "k8s cert-manager"
  assume_role_policy   = data.aws_iam_policy_document.cert-manager-trust.json
  permissions_boundary = data.aws_iam_policy.nocadmin-base.arn
}

data "aws_iam_policy_document" "cert-manager-trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [local.cluster_oidc_config.arn]
    }
    condition {
      test     = "StringEquals"
      variable = local.cluster_oidc_config.condition
      values   = ["system:serviceaccount:cert-manager:cert-manager"]
    }
  }
}

resource "aws_iam_role_policy" "cert-manager" {
  role   = aws_iam_role.cert-manager.name
  name   = "cert-manager"
  policy = data.aws_iam_policy_document.cert-manager-policy.json
}

data "aws_iam_policy_document" "cert-manager-policy" {
  statement {
    effect = "Allow"
    actions = [
      "route53:GetChange",
    ]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
    ]
    resources = sort([for zone in data.aws_route53_zone.zone : "arn:aws:route53:::hostedzone/${zone.id}"])
  }

  statement {
    effect = "Allow"
    actions = [
      "route53:ListHostedZonesByName"
    ]
    resources = [
      "*",
    ]
  }
}
