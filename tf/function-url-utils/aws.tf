provider "aws" {
  region              = "ap-northeast-1"
  allowed_account_ids = ["005216166247"]
  default_tags {
    tags = {
      Project   = "function-url-utils"
      Component = "function-url-utils"
    }
  }
}

provider "aws" {
  alias               = "usw2"
  region              = "us-west-2"
  allowed_account_ids = ["005216166247"]
  default_tags {
    tags = {
      Project   = "function-url-utils"
      Component = "function-url-utils"
    }
  }
}

data "aws_caller_identity" "current" {}
