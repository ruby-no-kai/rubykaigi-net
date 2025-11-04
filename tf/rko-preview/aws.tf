provider "aws" {
  region              = "us-west-2"
  allowed_account_ids = ["005216166247"]

  default_tags {
    tags = {
      Project = "rko-preview"
    }
  }
}

provider "aws" {
  alias               = "use1"
  region              = "us-east-1"
  allowed_account_ids = ["005216166247"]

  default_tags {
    tags = {
      Project = "rko-preview"
    }
  }
}

data "aws_caller_identity" "current" {}
