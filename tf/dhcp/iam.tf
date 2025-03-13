resource "kubernetes_service_account" "kea" {
  metadata {
    name      = "kea"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.kea.arn
      "eks.amazonaws.com/sts-regional-endpoints" = true
    }
  }
  automount_service_account_token = true
}

data "aws_iam_policy" "NocAdminBase" {
  name = "NocAdminBase"
}

resource "aws_iam_role" "kea" {
  name                 = "NetKea"
  description          = "rubykaigi-net//tf/dhcp"
  assume_role_policy   = data.aws_iam_policy_document.kea-trust.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

data "aws_iam_policy_document" "kea-trust" {
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
      values   = ["system:serviceaccount:default:kea"]
    }
  }
}

resource "aws_iam_role_policy" "kea" {
  role   = aws_iam_role.kea.name
  name   = "kea"
  policy = data.aws_iam_policy_document.kea-policy.json
}

data "aws_iam_policy_document" "kea-policy" {
  statement {
    effect = "Allow"
    actions = [
      "rds-db:connect",
    ]
    resources = [
      "arn:aws:rds-db:${data.aws_region.current.id}:${data.aws_caller_identity.current.id}:dbuser:${aws_rds_cluster.kea.cluster_resource_id}/kea-admin",
    ]
  }
}
