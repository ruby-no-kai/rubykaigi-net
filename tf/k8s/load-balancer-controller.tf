resource "helm_release" "load-balancer-controller" {
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.13.4" # 2.13.4

  name      = "aws-load-balancer-controller"
  namespace = kubernetes_namespace.platform.metadata.0.name

  values = [
    jsonencode({
      "clusterName" = module.cluster.config.name
      # Disable infer from IMDS, which would fail as now Karpenter sets httpPutResponseHopLimit=1 by default.
      "region" = data.aws_region.current.name
      "vpcId"  = data.aws_vpc.main.id

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
  depends_on = [module.cluster] # make sure coredns is running
}

data "aws_iam_policy" "nocadmin-base" {
  name = "NocAdminBase"
}

resource "aws_iam_role" "load-balancer-controller" {
  name                 = "NetLoadBalancerController"
  description          = "rubykaigi-net//tf/k8s: aws_iam_role.load-balancer-controller"
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
  url = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/2f6ce5cfc51a28257cf2710873c437257d1ef605/docs/install/iam_policy.json"

  lifecycle {
    postcondition {
      condition     = sha512(self.response_body) == "2ee899cbb1fe09f94dc714de73b3a7be111830a0ae10f0ee62f541b27443bdead2f639b44a561e312ec6960d54aa26f30bfa4c9642d292bb059ebf484236a872"
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
