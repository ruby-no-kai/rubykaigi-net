terraform {
  backend "s3" {
    bucket               = "rk-infra"
    workspace_key_prefix = "terraform"
    key                  = "terraform/netbox.tfstate"
    region               = "ap-northeast-1"
    use_lockfile         = true
  }
}
