terraform {
  backend "s3" {
    bucket       = "rk-infra"
    region       = "ap-northeast-1"
    key          = "terraform/nw-trapbridge.tfstate"
    use_lockfile = true
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

data "terraform_remote_state" "syslog" {
  backend = "s3"
  config = {
    bucket = "rk-infra"
    region = "ap-northeast-1"
    key    = "terraform/nw-syslog.tfstate"
  }
}
