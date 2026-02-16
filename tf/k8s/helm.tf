provider "helm" {
  kubernetes = {
    host                   = module.cluster.config.endpoint
    cluster_ca_certificate = base64decode(module.cluster.config.ca_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--region", "ap-northeast-1", "--cluster-name", module.cluster.config.name]
      command     = "aws"
    }
  }
}
