resource "helm_release" "grafana" {
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.52.9"

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

data "aws_lb_target_group" "common-grafana" {
  name = "rknw-common-grafana"
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
