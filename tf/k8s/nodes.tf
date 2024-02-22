module "karpenter" {
  #source = "github.com/cookpad/terraform-aws-eks//modules/karpenter?ref=943156dec7855fb3fd25f120b8fbdee42c9ae050"
  source = "github.com/sorah/terraform-aws-eks//modules/karpenter?ref=tmp-2-29"

  cluster_config = module.cluster.config
  oidc_config    = module.cluster.oidc_config
}


resource "helm_release" "karpenter" {
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "v0.34.0"

  name = "karpenter"

  namespace        = "karpenter"
  create_namespace = true

  values = [
    jsonencode({
      "settings" = {
        "clusterName"       = module.cluster.config.name
        "interruptionQueue" = "Karpenter-${module.cluster.config.name}"
      }
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

