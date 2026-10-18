data "aws_iam_policy" "NocAdminBase" {
  name = "NocAdminBase"
}

resource "aws_iam_role" "NetTrapbridge" {
  name                 = "NetTrapbridge"
  description          = "rubykaigi-net//tf/trapbridge"
  assume_role_policy   = data.aws_iam_policy_document.NetTrapbridge-trust.json
  permissions_boundary = data.aws_iam_policy.NocAdminBase.arn
}

data "aws_iam_policy_document" "NetTrapbridge-trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.cluster_oidc_config.arn]
    }
    condition {
      test     = "StringEquals"
      variable = local.cluster_oidc_config.condition
      values   = ["system:serviceaccount:default:trapbridge"]
    }
  }
}

resource "aws_iam_role_policy" "NetTrapbridge" {
  role   = aws_iam_role.NetTrapbridge.name
  name   = "NetTrapbridge"
  policy = data.aws_iam_policy_document.NetTrapbridge.json
}

data "aws_iam_policy_document" "NetTrapbridge" {
  statement {
    effect    = "Allow"
    actions   = ["events:PutEvents"]
    resources = ["arn:aws:events:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:event-bus/default"]
  }
}

resource "kubernetes_service_account_v1" "trapbridge" {
  metadata {
    name      = "trapbridge"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.NetTrapbridge.arn
      "eks.amazonaws.com/sts-regional-endpoints" = true
    }
  }
  automount_service_account_token = true
}
