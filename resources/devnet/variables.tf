variable "farmer_reward_address" {
  description = "Farmer's reward address"
  type        = string
}

variable "domain_id" {
  description = "Domain ID"
  type        = list(number)
  default     = [0, 1]
}

variable "domain_labels" {
  description = "Tag of the domain to run"
  type        = list(string)
  default     = ["nova", "autoid"]
}

variable "instance_type" {
  type = map(string)
  default = {
    bootstrap     = "c6a.2xlarge"
    rpc           = "m6a.xlarge"
    domain        = "m6a.xlarge"
    autoid        = "m6a.xlarge"
    full          = "m6a.xlarge"
    farmer        = "c7i.2xlarge"
    evm_bootstrap = "m6a.xlarge"
    autoid_bootstrap = "m6a.xlarge"
  }
}

variable "vpc_id" {
  default = "devnet-vpc"
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
    rpc           = 1
    domain        = 1
    autoid        = 1
    full          = 0
    farmer        = 1
    evm_bootstrap = 1
    autoid_bootstrap = 1
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
  default     = ["172.31.1.0/24"]
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
