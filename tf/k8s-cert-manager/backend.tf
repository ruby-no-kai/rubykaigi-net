terraform {
  backend "s3" {
    bucket         = "rk-infra"
    region         = "ap-northeast-1"
    key            = "terraform/nw-k8s-cert-manager.tfstate"
    dynamodb_table = "rk-terraform"
  }
}

data "terraform_remote_state" "k8s" {
  backend = "s3"
  config = {
    bucket = "rk-infra"
    region = "ap-northeast-1"
    key    = "terraform/nw-k8s.tfstate"
  }
}
