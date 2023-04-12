provider "helm" {
  kubernetes {
    host                   = local.cluster_config.endpoint
    cluster_ca_certificate = base64decode(local.cluster_config.ca_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--region", "ap-northeast-1", "--cluster-name", local.cluster_config.name]
      command     = "aws"
    }
  }
}
