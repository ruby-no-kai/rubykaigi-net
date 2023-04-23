data "aws_iam_policy" "nocadmin-base" {
  name = "NocAdminBase"
}

resource "aws_iam_role" "grafana" {
  name                 = "NwGrafana"
  description          = "k8s grafana"
  assume_role_policy   = data.aws_iam_policy_document.grafana-trust.json
  permissions_boundary = data.aws_iam_policy.nocadmin-base.arn
}

data "aws_iam_policy_document" "grafana-trust" {
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
      values   = ["system:serviceaccount:default:grafana"]
    }
  }
}

resource "aws_iam_role_policy" "grafana" {
  role   = aws_iam_role.grafana.name
  name   = "grafana"
  policy = data.aws_iam_policy_document.grafana-policy.json
}

data "aws_iam_policy_document" "grafana-policy" {
  statement {
    actions = [
      "logs:DescribeLogGroups",
      "logs:GetLogGroupFields",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:GetQueryResults",
      "logs:GetLogEvents",
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "tag:GetResources"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

