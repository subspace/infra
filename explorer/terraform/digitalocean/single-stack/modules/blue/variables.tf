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

variable "network_name" {
  description = "Network name"
  type        = string
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

variable "regions" {
  description = "Droplet region"
  type        = list(string)
  default     = ["AMS1", "NYC1"]
}
