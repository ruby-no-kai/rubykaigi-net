data "aws_iam_policy" "nocadmin-base" {
  name = "NocAdminBase"
}

resource "aws_iam_role" "acmesmith" {
  name                 = "NwAcmesmith"
  description          = "k8s acmesmith"
  assume_role_policy   = data.aws_iam_policy_document.acmesmith-trust.json
  permissions_boundary = data.aws_iam_policy.nocadmin-base.arn
}

resource "aws_iam_role_policy" "acmesmith" {
  role   = aws_iam_role.acmesmith.name
  name   = "acmesmith"
  policy = data.aws_iam_policy_document.acmesmith-policy.json
}

data "aws_iam_policy_document" "acmesmith-policy" {
  statement {
    effect    = "Allow"
    actions   = ["route53:ChangeResourceRecordSets", "route53:ListResourceRecordSets"]
    resources = ["arn:aws:route53:::hostedzone/${data.aws_route53_zone.rubykaigi_net.zone_id}"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["${data.aws_s3_bucket.rubykaigi-public.arn}/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["route53:ListHostedZones", "route53:GetChange"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "acmesmith-trust" {
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
      values   = ["system:serviceaccount:default:acmesmith"]
    }
  }
}
