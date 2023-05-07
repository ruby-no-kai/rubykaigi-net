provider "aws" {
  region              = "ap-northeast-1"
  allowed_account_ids = ["005216166247"]

  default_tags {
    tags = {
      Project   = "tftp"
      Component = "tftp"
    }
  }
}

data "aws_caller_identity" "current" {}
