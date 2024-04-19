terraform {
  backend "s3" {
    bucket         = "rk-infra"
    region         = "ap-northeast-1"
    key            = "terraform/nw-v6gw.tfstate"
    dynamodb_table = "rk-terraform"
  }
}
