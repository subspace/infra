resource "aws_vpc" "gh-runners" {
  cidr_block           = "172.31.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    name = "gh-runners"
  }
}

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.gh-runners.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = var.azs
  map_public_ip_on_launch = "true"

  tags = {
    Name = "gh-runner-public-subnet-${count.index + 1}"
  }
}


resource "aws_internet_gateway" "gw" {
  count  = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.gh-runners.id

  tags = {
    Name = "gh-runner-igw-public-subnet-${count.index}"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_route_table" "public_route_table" {
  count  = length(var.public_subnet_cidrs)
  vpc_id = aws_vpc.gh-runners.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw[count.index].id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw[count.index].id
  }

  tags = {
    Name = "gh-runner-public-route-tbl-${count.index}"
  }

  depends_on = [
    aws_internet_gateway.gw
  ]
}

resource "aws_route_table_association" "public_route_table_subnets_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = element(aws_route_table.public_route_table.*.id, count.index)
}

resource "aws_security_group" "allow_runner" {
  name        = "allow_runner"
  description = "Allow HTTP and HTTPS inbound traffic"
  vpc_id      = aws_vpc.gh-runners.id

  ingress {
    description = "HTTPS for VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP for VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH for VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WinRM for VPC"
    from_port   = 5985
    to_port     = 5985
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "RDP for VPC"
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "egress for VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_runner"
  }

  depends_on = [
    aws_vpc.gh-runners
  ]
}
