terraform {
  required_version = ">= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = "us-west-2"
  default_tags {
    tags = {
      Environment = "github runners autoscaling"
      Owner       = "subspace"
      Project     = "Subspace Network"
    }
  }
}
