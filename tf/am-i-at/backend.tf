terraform {
  backend "s3" {
    bucket         = "rk-infra"
    region         = "ap-northeast-1"
    key            = "terraform/am-i-at.tfstate"
    dynamodb_table = "rk-terraform"
  }
}
