terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    http = {
      source = "hashicorp/http"
    }
  }
  required_version = ">= 0.13"
}

provider "http" {}
