terraform {
  backend "s3" {
    bucket               = "rk-infra"
    workspace_key_prefix = "terraform"
    key                  = "terraform/sponsor-app.tfstate"
    region               = "ap-northeast-1"
    use_lockfile         = true
  }
}
