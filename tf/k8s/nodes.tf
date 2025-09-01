module "karpenter" {
  source = "github.com/cookpad/terraform-aws-eks//modules/karpenter?ref=f1c76b6d998a994bfd04f6fb20c04c95a98a6be7" # 1.32.0
  #source = "github.com/sorah/terraform-aws-eks//modules/karpenter?ref=tmp-2-29"

  v1beta = false
  v1     = true

  cluster_config = module.cluster.config
  oidc_config    = module.cluster.oidc_config
}


resource "helm_release" "karpenter" {
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.6.2"

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

