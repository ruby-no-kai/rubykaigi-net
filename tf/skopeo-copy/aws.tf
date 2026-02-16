data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  aws_account_id = "005216166247"
}

provider "aws" {
  region              = "ap-northeast-1"
  allowed_account_ids = [local.aws_account_id]
  default_tags {
    tags = {
      Project = "skopeo-copy"
    }
  }
}
