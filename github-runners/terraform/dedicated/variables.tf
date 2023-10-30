variable "gh_token" {
  default   = ""
  type      = string
  sensitive = true
}

variable "netdata_token" {
  default   = ""
  type      = string
  sensitive = true

}

variable "netdata_room" {
  default   = ""
  type      = string
  sensitive = true

}

variable "gh_runner_version" {
  type    = string
  default = "2.304.0"
}

variable "gh_runner_checksums" {
  type = map(string)
  default = {
    linux_x86_64   = "292e8770bdeafca135c2c06cd5426f9dda49a775568f45fcc25cc2b576afc12f",
    linux_arm64    = "34c49bd0e294abce6e4a073627ed60dc2f31eee970c13d389b704697724b31c6",
    mac_x86_64     = "26dddab8eafc193bb8b27afc5844ff3a6f789a655aca5bf79b018493963681a7",
    mac_arm64      = "789fc57af2f0819d470fcc447e2970f201cfc8aa1d803d4e5b748ec4c5d10db8",
    windows_x86_64 = "fbbddd2f94b195dde46aa6028acfe873351964c502aa9f29bb64e529b789500b"
  }
}

variable "instance_type" {
  default = ["t2.micro"]
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
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-2b", "us-east-1a"]
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

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["172.31.2.0/24"]
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
  default   = "deployer"
  type      = string
  sensitive = true
}

variable "public_key_path" {
  type    = string
  default = ""
}

variable "win_admin_username" {
  default   = "default"
  type      = string
  sensitive = true
}


variable "win_admin_password" {
  default   = "default"
  type      = string
  sensitive = true
}
