terraform {
  backend "s3" {
    bucket         = "rk-infra"
    region         = "ap-northeast-1"
    key            = "terraform/nw-acme-responder.tfstate"
    dynamodb_table = "rk-terraform"
  }
}
