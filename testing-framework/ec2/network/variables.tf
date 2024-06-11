variable "farmer_reward_address" {
  description = "Farmer's reward address"
  type        = string
}

//todo change this to a map
variable "domain_id" {
  description = "Domain ID"
  type        = list(number)
  default     = [0, 1]
}

//todo change this to a map
variable "domain_labels" {
  description = "Tag of the domain to run"
  type        = list(string)
  default     = ["nova", "autoid"]
}

variable "instance_type" {
  default = "m6a.xlarge"
  type    = string
}

variable "network_name" {
  description = "Network name"
  type        = string
  default     = "devnet"
}

variable "vpc_id" {
  type = string
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
    bootstrap        = 1
    node             = 1
    farmer           = 1
    domain           = 1
    autoid           = 1
    evm_bootstrap    = 1
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

variable "private_key_path" {
  type    = string
  default = "~/.ssh/deployer.pem"
}

variable "ssh_user" {
  type    = string
  default = "ubuntu"
}

variable "tf_token" {
  type      = string
  sensitive = true
}

variable "branch_name" {
  description = "name of testing branch"
  type        = string
}

variable "genesis_hash" {
  description = "Genesis hash"
  type        = string
}
