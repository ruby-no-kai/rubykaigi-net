terraform {
  backend "s3" {
    bucket         = "rk-infra"
    region         = "ap-northeast-1"
    key            = "terraform/vpc-usw2.tfstate"
    dynamodb_table = "rk-terraform"
  }
}
