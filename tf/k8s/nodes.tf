module "karpenter" {
  source = "github.com/cookpad/terraform-aws-eks//modules/karpenter?ref=1.34.0"

  cluster_config = module.cluster.config
  oidc_config    = module.cluster.oidc_config
}


resource "helm_release" "karpenter" {
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.9.0"

  name = "karpenter"

  namespace        = "karpenter"
  create_namespace = true

  values = [
    jsonencode({
      "settings" = {
        "clusterName"       = module.cluster.config.name
        "interruptionQueue" = "Karpenter-${module.cluster.config.name}"
      }
      "featureGates" = {
        "spotToSpotConsolidation" = true
      }
      dnsPolicy = "Default" # Karpenter starts nodes for CoreDNS
      replicas  = 1         # Fargate
      "controller" = {
        "resources" = {
          "requests" = {
            "cpu"    = "250m"
            "memory" = "250Mi"
          }
        }
      }
      "serviceAccount" = {
        "annotations" = {
          "eks.amazonaws.com/role-arn" = replace(module.karpenter.node_role_arn, "Node-", "-")
        }
      }
    }),
  ]

  depends_on = [module.karpenter]
}

