variable "network_name" {
  description = "Network name"
  type        = string
  default     = "gemini-3h"

}
variable "farmer_reward_address" {
  description = "Farmer's reward address"
  type        = string
}

//todo change this to a map
variable "domain_id" {
  description = "Domain ID"
  type        = list(number)
  default     = [0]
}

//todo change this to a map
variable "domain_labels" {
  description = "Tag of the domain to run"
  type        = list(string)
  default     = ["evm"]
}

variable "instance_type" {
  type = map(string)
  default = {
    bootstrap     = "c7a.2xlarge"
    rpc           = "m7a.xlarge"
    domain        = "m7a.xlarge"
    rpc-squid     = "c7a.2xlarge"
    nova-squid    = "c7a.2xlarge"
    farmer        = "c7a.2xlarge"
    evm_bootstrap = "c7a.xlarge"
  }
}

variable "vpc_id" {
  default = "gemini-3h-vpc"
  type    = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "azs" {
  type        = string
  description = "Availability Zones"
  default     = "us-east-1a"
}

variable "instance_count" {
  type = map(number)
  default = {
    bootstrap     = 2
    rpc           = 2
    domain        = 2
    rpc-squid     = 1
    nova-squid    = 1
    farmer        = 0
    evm_bootstrap = 1
  }
}

variable "aws_region" {
  description = "aws region"
  type        = list(string)
  default     = ["us-east-1"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["172.35.1.0/24"]
}

variable "disk_volume_size" {
  type = number
}

variable "disk_volume_type" {
  type    = string
  default = "gp3"
}

variable "secret_key" {
  type      = string
  sensitive = true
}

variable "access_key" {
  type      = string
  sensitive = true
}

variable "aws_key_name" {
  default = "deployer"
  type    = string
}

variable "ssh_user" {
  default = "ubuntu"
  type    = string
}

variable "private_key_path" {
  type    = string
  default = "~/.ssh/deployer.pem"
}

variable "pot_external_entropy" {
  description = "External entropy, used initially when PoT chain starts to derive the first seed"
  type        = string
  default     = "test"
}
