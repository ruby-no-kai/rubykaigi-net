provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.rk22.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.rk22.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--region", "ap-northeast-1", "--cluster-name", data.aws_eks_cluster.rk22.name]
      command     = "aws"
    }
  }
}
