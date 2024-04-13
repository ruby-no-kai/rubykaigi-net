terraform {
  backend "s3" {
    bucket         = "rk-infra"
    region         = "ap-northeast-1"
    key            = "terraform/bastion.tfstate"
    dynamodb_table = "rk-terraform"
  }
}
