# node-termination-handler in IMDS mode

resource "helm_release" "node-termination-handler" {
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-node-termination-handler"
  version    = "0.21.0" # 1.19.0

  name      = "aws-node-termination-handler"
  namespace = "kube-system"


  set {
    name  = "enableSpotInterruptionDraining"
    value = "true"
  }
  set {
    name  = "enableRebalanceMonitoring"
    value = "true"
  }
  set {
    name  = "enableScheduledEventDraining"
    value = "true"
  }
  set {
    name  = "webhookURL"
    value = data.aws_ssm_parameter.slack-webhook-url.value
  }
}

