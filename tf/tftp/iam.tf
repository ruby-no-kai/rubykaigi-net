data "aws_iam_policy" "nocadmin-base" {
  name = "NocAdminBase"
}

resource "aws_iam_role" "s3tftpd" {
  name                 = "NetTftp"
  description          = "k8s s3tftpd"
  assume_role_policy   = data.aws_iam_policy_document.s3tftpd-trust.json
  permissions_boundary = data.aws_iam_policy.nocadmin-base.arn
}

data "aws_iam_policy_document" "s3tftpd-trust" {
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
      values   = ["system:serviceaccount:default:s3tftpd"]
    }
  }
}

resource "aws_iam_role_policy" "s3tftpd" {
  role   = aws_iam_role.s3tftpd.name
  name   = "s3tftpd"
  policy = data.aws_iam_policy_document.s3tftpd-policy.json
}

data "aws_iam_policy_document" "s3tftpd-policy" {
  statement {
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.tftp.arn,
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.tftp.arn}/rw/*",
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.tftp.arn}/ro/*",
      "${aws_s3_bucket.tftp.arn}/tftpboot/*",
      "${aws_s3_bucket.tftp.arn}/ping",
    ]
    effect = "Allow"
  }
  statement {
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.tftp.arn}/wo/*",
    ]
    effect = "Allow"
  }

}

