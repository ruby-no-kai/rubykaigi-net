terraform {
  backend "s3" {
    bucket       = "rk-infra"
    region       = "ap-northeast-1"
    key          = "terraform/sts-cat.tfstate"
    use_lockfile = true
  }
}
