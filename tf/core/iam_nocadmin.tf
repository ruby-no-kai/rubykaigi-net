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

resource "aws_iam_role_policy" "nocadmin" {
  role   = aws_iam_role.NocAdmin.name
  policy = data.aws_iam_policy_document.nocadmin.json
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
      "kms:*",
      "lambda:*",
      "logs:*",
      "medialive:*",
      "rds:*",
      "route53:*",
      "ssm:*",
      "transcribe:*",

      "s3:ListMyBuckets",
      "s3:GetBucketLocation",
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

resource "aws_iam_role_policy_attachment" "nocadmin-iam-ro" {
  role       = aws_iam_role.NocAdmin.name
  policy_arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}
