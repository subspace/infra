terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.55.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">=4.7.0"
    }
  }
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.aws_region[0]
  default_tags {
    tags = {
      Owner   = "subspace"
      Project = "Subspace Cloud HSM"
    }
  }
}
