resource "helm_release" "cloudwatch-exporter-apne1" {
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-cloudwatch-exporter"
  version    = "0.28.1" # 0.16.0

  name = "cloudwatch-exporter-apne1"

  values = [
    data.external.cloudwatch-exporter-values.result.json,
    jsonencode({
      config = data.external.cloudwatch-exporter-config-apne1.result.json
      serviceMonitor = {
        enabled  = true
        interval = "300s"
        timeout  = "300s"
        labels = {
          release = helm_release.kube-prometheus-stack.name
        }
      }
    })
  ]
}

data "external" "cloudwatch-exporter-config-apne1" {
  program = ["../jsonnet.rb"]

  query = {
    path = "./cloudwatch-exporter.config/apne1.jsonnet"
  }
}

resource "helm_release" "cloudwatch-exporter-apne1hi" {
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-cloudwatch-exporter"
  version    = "0.28.1" # 0.16.0

  name = "cloudwatch-exporter-apne1hi"

  values = [
    data.external.cloudwatch-exporter-values.result.json,
    jsonencode({
      config = data.external.cloudwatch-exporter-config-apne1hi.result.json
      serviceMonitor = {
        enabled  = true
        interval = "300s"
        timeout  = "300s"
        labels = {
          release = helm_release.kube-prometheus-stack.name
        }
      }
    })
  ]
}

data "external" "cloudwatch-exporter-config-apne1hi" {
  program = ["../jsonnet.rb"]

  query = {
    path = "./cloudwatch-exporter.config/apne1hi.jsonnet"
  }
}

data "external" "cloudwatch-exporter-values" {
  program = ["../jsonnet.rb"]

  query = {
    path = "./cloudwatch-exporter.jsonnet"
  }
}

data "aws_iam_policy" "nocadmin-base" {
  name = "NocAdminBase"
}

resource "aws_iam_role" "cloudwatch-exporter" {
  name                 = "NwCloudWatchExporter"
  description          = "k8s cloudwatch_exporter"
  assume_role_policy   = data.aws_iam_policy_document.cloudwatch-exporter-trust.json
  permissions_boundary = data.aws_iam_policy.nocadmin-base.arn
}

data "aws_iam_policy_document" "cloudwatch-exporter-trust" {
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
      values   = ["system:serviceaccount:default:cloudwatch-exporter"]
    }
  }
}

resource "aws_iam_role_policy" "cloudwatch-exporter" {
  role   = aws_iam_role.cloudwatch-exporter.name
  name   = "cloudwatch-exporter"
  policy = data.aws_iam_policy_document.cloudwatch-exporter-policy.json
}

data "aws_iam_policy_document" "cloudwatch-exporter-policy" {
  statement {
    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "kubernetes_service_account_v1" "cloudwatch-exporter" {
  metadata {
    name = "cloudwatch-exporter"
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.cloudwatch-exporter.arn
      "eks.amazonaws.com/sts-regional-endpoints" = true
    }
  }
  automount_service_account_token = true
}
