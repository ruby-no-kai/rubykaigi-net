provider "aws" {
  region              = "ap-northeast-1"
  allowed_account_ids = ["005216166247"]
  default_tags {
    tags = {
      Project   = "signage-app"
      Component = "signage-app"
    }
  }
}

provider "aws" {
  alias               = "use1"
  region              = "us-east-1"
  allowed_account_ids = ["005216166247"]

  default_tags {
    tags = {
      Project   = "signage-app"
      Component = "signage-app"
    }
  }
}

data "aws_caller_identity" "current" {}
