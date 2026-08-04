terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    helm = {
      source = "hashicorp/helm"
    }

    tls = {
      source = "hashicorp/tls"
    }

  }
}