terraform {
  required_version = ">= 0.15.0"

  required_providers {
    aws        = ">= 3.22.0"
    local      = ">= 1.4"
    random     = ">= 2.1"
    kubernetes = "~> 1.11"
    helm       = "~> 1.3.1"
  }

  backend "s3" {
    bucket                  = "eks-infinity-terraform-state-dfgsdf"
    workspace_key_prefix    = "infra"
    key                     = "statefile"
    region                  = "eu-west-1"
    shared_credentials_file = "~/.aws/credentials"
    profile                 = "hf-sm"
  }
}

provider "aws" {
  region                  = var.region
  shared_credentials_file = "~/.aws/credentials"
  profile                 = var.profile
}

