resource "helm_release" "kube-prometheus-stack" {
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "57.2.0"

  name = "kube-prometheus-stack"

  values = [data.external.kube-prometheus-stack-values.result.json]
}

data "external" "kube-prometheus-stack-values" {
  program = ["../jsonnet.rb"]

  query = {
    path = "./kube-prometheus-stack.jsonnet"
  }
}

data "aws_lb_target_group" "common-prometheus" {
  name = "rknw-common-prometheus"
}

resource "kubernetes_manifest" "targetgroupbinding-prometheus" {
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind"       = "TargetGroupBinding"
    "metadata" = {
      "name"      = "prometheus"
      "namespace" = "default"
    }

    "spec" = {
      "serviceRef" = {
        "name" = "prometheus-operated"
        "port" = 9090
      },
      "targetGroupARN" = data.aws_lb_target_group.common-prometheus.arn
    }
  }
}

data "aws_lb_target_group" "common-alertmanager" {
  name = "rknw-common-alertmanager"
}

resource "kubernetes_manifest" "targetgroupbinding-alertmanager" {
  manifest = {
    "apiVersion" = "elbv2.k8s.aws/v1beta1"
    "kind"       = "TargetGroupBinding"
    "metadata" = {
      "name"      = "alertmanager"
      "namespace" = "default"
    }

    "spec" = {
      "serviceRef" = {
        "name" = "alertmanager-operated"
        "port" = 9093
      },
      "targetGroupARN" = data.aws_lb_target_group.common-alertmanager.arn
    }
  }
}

resource "kubernetes_secret" "alertmanager-slack-webhook" {
  metadata {
    name = "alertmanager-slack-webhook"
  }

  data = {
    url = data.aws_ssm_parameter.slack-webhook-url.value
  }
}

data "aws_ssm_parameter" "slack-webhook-url" {
  name = "/misc/network-slack-webhook-url"
}
