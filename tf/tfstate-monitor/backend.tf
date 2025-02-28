terraform {
  backend "s3" {
    bucket         = "rk-infra"
    region         = "ap-northeast-1"
    key            = "terraform/tfstate-monitor.tfstate"
    dynamodb_table = "rk-terraform"
  }
}
