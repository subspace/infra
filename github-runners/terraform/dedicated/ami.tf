data "aws_ami" "ubuntu_x86_64" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"]
}

data "aws_ami" "ubuntu_arm64" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  owners = ["099720109477"]
}


data "aws_ami" "mac_x86_64" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ec2-macos-12.6.3-20230201-041127"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64_mac"]
  }

  owners = ["634519214787"]
}


data "aws_ami" "mac_arm64" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ec2-macos-12.6.3-20230201-190453-arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64_mac"]
  }

  owners = ["634519214787"]
}


data "aws_ami" "windows_x86_64" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-2023.04.12"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["801119661308"]
}
