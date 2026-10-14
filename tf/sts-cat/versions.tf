terraform {
  required_version = ">= 1.11"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.36"
    }
    http = {
      source = "hashicorp/http"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}
