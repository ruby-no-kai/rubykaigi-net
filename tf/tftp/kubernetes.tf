data "terraform_remote_state" "k8s" {
  backend = "s3"
  config = {
    bucket = "rk-infra"
    region = "ap-northeast-1"
    key    = "terraform/nw-k8s.tfstate"
  }
}
locals {
  cluster_config      = data.terraform_remote_state.k8s.outputs.cluster_config
  cluster_oidc_config = data.terraform_remote_state.k8s.outputs.cluster_oidc_config
}
