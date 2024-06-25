variable "github_app" {
  description = "GitHub for API usages."

  type = object({
    id         = string
    key_base64 = string
  })
}

variable "environment" {
  description = "Environment name, used as prefix"

  type    = string
  default = "multi-runner"
}

variable "aws_region" {
  description = "AWS region to deploy to"

  type    = string
  default = "us-west-2"
}
