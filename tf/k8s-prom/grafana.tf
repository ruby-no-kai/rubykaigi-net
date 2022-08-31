resource "helm_release" "grafana" {
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.34.0"

  name             = "grafana"
  namespace        = "monitoring"
  create_namespace = true

  values = [data.external.grafana-values.result.json]
}

data "external" "grafana-values" {
  program = ["../jsonnet.rb"]

  query = {
    path = "./grafana.values.jsonnet"
  }
}

data "aws_lb_target_group" "common-grafana" {
  name = "rknw-common-grafana"
}

resource "kubernetes_manifest" "targetgroupbinding-grafana" {
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind"       = "TargetGroupBinding"
    "metadata"   = {
      "name"      = "grafana"
      "namespace" = "monitoring"
    }

    "spec" = {
      "serviceRef"     = {
        "name" = "grafana"
        "port" = 80
      },
      "targetGroupARN" = data.aws_lb_target_group.common-grafana.arn
    }
  }
}