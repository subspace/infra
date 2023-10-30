terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.55.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.18.0"
    }
  }
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = "us-east-2"
  default_tags {
    tags = {
      Environment = "Development"
      Owner       = "subspace"
      Project     = "Subspace Network"
    }
  }
}
