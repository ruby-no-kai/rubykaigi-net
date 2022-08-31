terraform {
  backend "s3" {
    bucket = "rk-infra"
    region = "ap-northeast-1"
    key    = "terraform/nw-wgbridger.tfstate"
    dynamodb_table = "rk-terraform"
  }
}
