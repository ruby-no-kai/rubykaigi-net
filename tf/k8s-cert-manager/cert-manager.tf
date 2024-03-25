locals {
  namespace            = "cert-manager"
  service_account_name = "cert-manager"
}

resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = local.namespace
  }
}

resource "helm_release" "cert-manager" {
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.14.4"

  name      = "cert-manager"
  namespace = local.namespace

  values = [
    data.external.cert-manager-values.result.json,
    jsonencode({
      serviceAccount = {
        create = false,
        name   = local.service_account_name,
      },
    })
  ]

  depends_on = [
    kubernetes_namespace.cert-manager,
    kubernetes_service_account.cert-manager,
  ]
}

data "external" "cert-manager-values" {
  program = ["${path.module}/../jsonnet.rb"]

  query = {
    path = "./cert-manager.jsonnet"
  }
}

resource "kubernetes_service_account" "cert-manager" {
  metadata {
    name      = local.service_account_name
    namespace = local.namespace
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.cert-manager.arn
      "eks.amazonaws.com/sts-regional-endpoints" = true
    }
  }
  automount_service_account_token = true

  depends_on = [
    kubernetes_namespace.cert-manager,
  ]
}
