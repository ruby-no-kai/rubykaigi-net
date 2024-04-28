provider "aws" {
  region              = "ap-northeast-1"
  allowed_account_ids = ["005216166247"]
  default_tags {
    tags = {
      Project   = "dot-net"
      Component = "dot-net"
    }
  }
}

provider "aws" {
  alias               = "use1"
  region              = "us-east-1"
  allowed_account_ids = ["005216166247"]

  default_tags {
    tags = {
      Project   = "dot-net"
      Component = "dot-net"
    }
  }
}

data "aws_caller_identity" "current" {}
