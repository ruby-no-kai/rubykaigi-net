terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.26"
    }
  }
  required_version = ">= 0.13"
}
