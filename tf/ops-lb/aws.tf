provider "aws" {
  alias               = "apne1"
  region              = "ap-northeast-1"
  allowed_account_ids = ["005216166247"]
}
provider "aws" {
  alias               = "use1"
  region              = "us-east-1"
  allowed_account_ids = ["005216166247"]
}

data "aws_caller_identity" "current" {}
