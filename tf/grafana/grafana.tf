resource "helm_release" "grafana" {
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "8.10.3"

  name = "grafana"

  values = [
    data.external.grafana-values.result.json,
    jsonencode({
      "grafana.ini" = {
        "auth.generic_oauth" = local.oidc_config,
      },
      serviceAccount = {
        name = "grafana"
        annotations = {
          "eks.amazonaws.com/role-arn"               = aws_iam_role.grafana.arn
          "eks.amazonaws.com/sts-regional-endpoints" = "true"
        }
      },
    }),
  ]

  depends_on = [
    kubernetes_secret.grafana-admin,
    kubernetes_secret.oidc-client,
    null_resource.rds-provision,
  ]
}

data "external" "grafana-values" {
  program = ["../jsonnet.rb"]

  query = {
    path = "./grafana.jsonnet"
    args = jsonencode({
      role_public  = aws_iam_role.grafana-public.arn,
      role_private = aws_iam_role.grafana-private.arn,
    })
  }
}

ephemeral "random_password" "grafana-admin" {
  length  = 64
  special = false
}
resource "aws_ssm_parameter" "grafana-admin" {
  name             = "/grafana/admin"
  type             = "SecureString"
  value_wo         = ephemeral.random_password.grafana-admin.result
  value_wo_version = 1
}
ephemeral "aws_ssm_parameter" "grafana-admin" {
  arn = aws_ssm_parameter.grafana-admin.arn
}

resource "kubernetes_secret" "grafana-admin" {
  metadata {
    name = "grafana-admin"
  }

  data_wo_revision = 1
  data_wo = {
    username = "admin"
    password = ephemeral.aws_ssm_parameter.grafana-admin.value
  }

  type = "kubernetes.io/basic-auth"
}

data "aws_lb_target_group" "common-grafana" {
  name = "rknet-common-grafana"
}

resource "kubernetes_manifest" "targetgroupbinding-grafana" {
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind"       = "TargetGroupBinding"
    "metadata" = {
      "name"      = "grafana"
      "namespace" = "default"
    }

    "spec" = {
      "serviceRef" = {
        "name" = "grafana"
        "port" = 80
      },
      "targetGroupARN" = data.aws_lb_target_group.common-grafana.arn
    }
  }
}
