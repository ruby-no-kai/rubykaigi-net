provider "aws" {
  region              = "ap-northeast-1"
  allowed_account_ids = ["005216166247"]

  default_tags {
    tags = {
      Project   = "rk26net"
      Component = "dhcp"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
