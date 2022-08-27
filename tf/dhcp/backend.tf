terraform {
  backend "s3" {
    bucket = "rk-infra"
    region = "ap-northeast-1"
    key    = "terraform/nw-dhcp.tfstate"
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
