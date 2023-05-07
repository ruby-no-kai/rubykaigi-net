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

# When chaining AssumeRole, Principal clause has to exactly match the :assumed-role/ session principal,
# which includes a random session name.
# OTOH, aws:PrincipalArn variable in Condition clause exposes :role/ principal.
data "aws_iam_policy_document" "grafana-chain-trust" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:PrincipalArn"
      test     = "ArnEquals"
      values = [
        aws_iam_role.grafana.arn,
      ]
    }
  }
}

data "aws_iam_policy_document" "grafana-policy" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      aws_iam_role.grafana-private.arn,
      aws_iam_role.grafana-public.arn,
    ]
    effect = "Allow"
  }
}

resource "aws_iam_role" "grafana-private" {
  name                 = "NwGrafanaPrivate"
  description          = "k8s grafana private"
  assume_role_policy   = data.aws_iam_policy_document.grafana-chain-trust.json
  permissions_boundary = data.aws_iam_policy.nocadmin-base.arn
}

resource "aws_iam_role_policy" "grafana-private" {
  role   = aws_iam_role.grafana-private.name
  name   = "grafana"
  policy = data.aws_iam_policy_document.grafana-private-policy.json
}

data "aws_iam_policy_document" "grafana-private-policy" {
  statement {
    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetInsightRuleReport",
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

resource "aws_iam_role" "grafana-public" {
  name                 = "NwGrafanaPublic"
  description          = "k8s grafana public"
  assume_role_policy   = data.aws_iam_policy_document.grafana-chain-trust.json
  permissions_boundary = data.aws_iam_policy.nocadmin-base.arn
}

resource "aws_iam_role_policy" "grafana-public" {
  role   = aws_iam_role.grafana-public.name
  name   = "grafana"
  policy = data.aws_iam_policy_document.grafana-public-policy.json
}

data "aws_iam_policy_document" "grafana-public-policy" {
  statement {
    actions = [
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetInsightRuleReport",
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions",
      "tag:GetResources"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}
