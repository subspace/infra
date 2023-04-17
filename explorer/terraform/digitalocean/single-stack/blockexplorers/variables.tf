variable "do_token" {
  description = "Digital ocean API key"
}

variable "ssh_identity" {
  description = "SSH agent identity to use to connect to remote host"
}

variable "datadog_api_key" {
  description = "Datadog API Key"
}

variable "cloudflare_email" {
  type        = string
  description = "cloudflare email address"
}

variable "cloudflare_api_token" {
  type        = string
  description = "cloudflare api token"
}

variable "droplet_size" {
  description = "Droplet size"
  type        = string
  default     = "m6-2vcpu-16gb"
}

variable "deployment_color" {
  description = "Deployment environment"
  type        = string
  default     = "blue"
}

variable "explorer-node-config" {
  description = "Block explorer backend configuration"
  type = object({
    droplet-size     = string
    deployment-color = string
    regions          = list(string)
    nodes-per-region = number
    docker-org       = string
    docker-tag       = string
    prune            = bool
    environment      = string
  })

  default = {
    droplet-size     = "value"
    deployment-color = "blue"
    regions          = ["AMS3", "NYC1"]
    nodes-per-region = 1
    docker-org       = "subspace"
    docker-tag       = "value"
    prune            = false
    environment      = "staging"
  }
}

variable "squid-archive-node-config" {
  description = "Squid Archive configuration"
  type = object({
    droplet_size           = string
    deployment_color       = string
    regions                = list(string)
    nodes-per-region       = number
    docker-org             = string
    docker-tag             = string
    prune                  = bool
    environment = string
  })
  
  default = {
    droplet-size = "value"
    deployment-color = "blue"
    regions = ["AMS3", "NYC1"]
    nodes-per-region = 1
    docker-org = "subspace"
    docker-tag = "value"
    environment = "staging"
    prune = false
  }
}