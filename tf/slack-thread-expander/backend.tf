terraform {
  backend "s3" {
    bucket         = "rk-infra"
    region         = "ap-northeast-1"
    key            = "terraform/slack-thread-expander.tfstate"
    dynamodb_table = "rk-terraform"
  }
}
