variable "gh_token" {
  type      = string
  sensitive = true
}

variable "netdata_token" {
  type      = string
  sensitive = true

}

variable "netdata_room" {
  type      = string
  sensitive = true

}

variable "gh_runner_version" {
  type    = string
  default = "2.309.0"
}

variable "gh_runner_checksums" {
  type = map(string)
  default = {
    linux_x86_64   = "",
    linux_arm64    = "",
    mac_x86_64     = "",
    mac_arm64      = "",
    windows_x86_64 = ""
  }
}

variable "instance_type" {
  default = ["t3.2xlarge", "m6i.2xlarge"]
  type    = list(string)
}

variable "instance_type_mac" {
  default = ["mac1.metal", "mac2.metal"]
  type    = list(string)
}

variable "instance_type_arm" {
  default = ["a1.2xlarge", "a1.4xlarge"]
  type    = list(string)
}

variable "vpc_id" {
  default = "default"
  type    = string
}

variable "azs" {
  type        = string
  description = "Availability Zones"
  default     = "us-east-2b"
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "aws_region" {
  description = "aws region"
  type        = list(string)
  default     = ["us-east-2"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["172.31.1.0/24"]
}

variable "secret_key" {
  type      = string
  sensitive = true
}

variable "ssh_user" {
  type    = list(string)
  default = ["ubuntu", "ec2-user"]

}

variable "access_key" {
  type      = string
  sensitive = true
}

variable "aws_key_name" {
  default   = "deployer"
  type      = string
  sensitive = true
}

variable "private_key_path" {
  type = string
}

variable "win_admin_username" {
  type = string
}


variable "win_admin_password" {
  type      = string
  sensitive = true
}
