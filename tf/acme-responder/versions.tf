terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.6"
    }
  }
  required_version = ">= 0.13"
}
