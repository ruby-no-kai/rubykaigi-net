provider "aws" {
  region              = "ap-northeast-1"
  allowed_account_ids = ["005216166247"]
  default_tags {
    tags = {
      Project = "rubykaigi-net-core"
    }
  }
}
provider "aws" {
  alias               = "use1"
  region              = "us-east-1"
  allowed_account_ids = ["005216166247"]
  default_tags {
    tags = {
      Project = "rubykaigi-net-core"
    }
  }
}
provider "aws" {
  alias               = "usw2"
  region              = "us-west-2"
  allowed_account_ids = ["005216166247"]
  default_tags {
    tags = {
      Project = "rubykaigi-net-core"
    }
  }
}

data "aws_caller_identity" "current" {}
