terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    archive = {
      source = "hashicorp/archive"
    }
    null = {
      source = "hashicorp/null"
    }
    external = {
      source = "hashicorp/external"
    }
  }
  required_version = ">= 0.13"
}

provider "archive" {}
provider "null" {}
provider "external" {}
