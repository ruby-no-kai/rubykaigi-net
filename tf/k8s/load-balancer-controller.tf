resource "helm_release" "load-balancer-controller" {
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.11.0" # 2.11.0

  name      = "aws-load-balancer-controller"
  namespace = kubernetes_namespace.platform.metadata.0.name

  values = [
    jsonencode({
      "clusterName" = module.cluster.config.name
      # SA has to be created manually to enable eks pod iam role
      "serviceAccount" = {
        "name"   = kubernetes_service_account.load-balancer-controller.metadata.0.name
        "create" = false
      }
      "affinity" = {
        "podAntiAffinity" = {
          "preferredDuringSchedulingIgnoredDuringExecution" = [
            {
              "weight" = 100
              "podAffinityTerm" = {
                "topologyKey" = "topology.kubernetes.io/zone"
                "labelSelector" = {
                  "matchExpressions" = [
                    {
                      "key"      = "app.kubernetes.io/name"
                      "operator" = "In"
                      "values"   = ["aws-load-balancer-controller"]
                    }
                  ]
                }
              }
            },
            {
              "weight" = 50
              "podAffinityTerm" = {
                "topologyKey" = "kubernetes.io/hostname"
                "labelSelector" = {
                  "matchExpressions" = [
                    {
                      "key"      = "app.kubernetes.io/name"
                      "operator" = "In"
                      "values"   = ["aws-load-balancer-controller"]
                    }
                  ]
                }
              }
            }
          ]
        }
      }
    }),
  ]
}

data "aws_iam_policy" "nocadmin-base" {
  name = "NocAdminBase"
}

resource "aws_iam_role" "load-balancer-controller" {
  name                 = "NwLoadBalancerController"
  description          = "rubykaigi-net//k8s/aws_iam_role.load-balancer-controller"
  assume_role_policy   = data.aws_iam_policy_document.load-balancer-controller-trust.json
  permissions_boundary = data.aws_iam_policy.nocadmin-base.arn
}

data "aws_iam_policy_document" "load-balancer-controller-trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [module.cluster.oidc_config.arn]
    }
    condition {
      test     = "StringEquals"
      variable = module.cluster.oidc_config.condition
      values   = ["system:serviceaccount:platform:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role_policy" "load-balancer-controller" {
  role   = aws_iam_role.load-balancer-controller.name
  name   = "load-balancer-controller"
  policy = data.http.load-balancer-controller-policy.response_body
}

data "http" "load-balancer-controller-policy" {
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/refs/heads/main/docs/install/iam_policy.json"

  lifecycle {
    postcondition {
      condition     = sha512(self.response_body) == "0e2858449d1d284834c4776a6a8c40f5f20e8406e34c603447ec21f363d68a293bbff2a4c287afb04b991aee5aff6edbcfe5eda9ccfb66a8852bb32192ea18f9"
      error_message = "checksum mismatch"
    }
  }
}

resource "kubernetes_service_account" "load-balancer-controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = kubernetes_namespace.platform.metadata.0.name
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.load-balancer-controller.arn
      "eks.amazonaws.com/sts-regional-endpoints" = true
    }
  }
  automount_service_account_token = true
}

resource "kubernetes_labels" "pod-readiness-gate-inject" {
  api_version = "v1"
  kind        = "Namespace"
  metadata {
    name = "default"
  }
  labels = {
    # https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.4/deploy/pod_readiness_gate/
    "elbv2.k8s.aws/pod-readiness-gate-inject" = "enabled"
  }
}

# module.cluster.oidc_config.url
# module.cluster.oidc_config.arn
# module.cluster.oidc_config.condition
