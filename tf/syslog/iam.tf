data "aws_iam_policy" "nocadmin-base" {
  name = "NocAdminBase"
}

resource "aws_iam_role" "syslog" {
  name                 = "NetSyslog"
  description          = "k8s syslog"
  assume_role_policy   = data.aws_iam_policy_document.syslog-trust.json
  permissions_boundary = data.aws_iam_policy.nocadmin-base.arn
}

data "aws_iam_policy_document" "syslog-trust" {
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
      values   = ["system:serviceaccount:default:syslog"]
    }
  }
}

resource "aws_iam_role_policy" "syslog" {
  role   = aws_iam_role.syslog.name
  name   = "fluentd-s3"
  policy = data.aws_iam_policy_document.fluentd-s3-policy.json
}

data "aws_iam_policy_document" "fluentd-s3-policy" {
  statement {
    actions = [
      "s3:PutObject",
    ]
    resources = ["arn:aws:s3:::rk-syslog/*", ]
    effect    = "Allow"
  }
}

resource "kubernetes_service_account" "syslog" {
  metadata {
    name      = "syslog"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.syslog.arn
      "eks.amazonaws.com/sts-regional-endpoints" = true
    }
  }
  automount_service_account_token = true
}
