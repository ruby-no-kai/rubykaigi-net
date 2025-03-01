module "karpenter" {
  source = "github.com/cookpad/terraform-aws-eks//modules/karpenter?ref=70a90da1066f428a705b66a42266b6e482e818da"
  #source = "github.com/sorah/terraform-aws-eks//modules/karpenter?ref=tmp-2-29"

  v1beta = false
  v1     = true

  cluster_config = module.cluster.config
  oidc_config    = module.cluster.oidc_config
}


resource "helm_release" "karpenter" {
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.2.2"

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
          "eks.amazonaws.com/role-arn" = "arn:aws:iam::005216166247:role/NetEksKarpenter-rknet"
        }
      }
    }),
  ]

  depends_on = [module.karpenter]
}

