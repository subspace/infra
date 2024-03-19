module "bootstrap_node" {
  source = "../../terraform/aws/ec2"

  count              = length(var.aws_region) * var.bootstrap-node-config.instance-count
  ami                = data.aws_ami.ubuntu_amd64.image_id
  instance_type      = var.bootstrap-node-config.instance-type
  subnet_id          = element(aws_subnet.public_subnets.*.id, 0)
  availability_zone  = var.azs
  ipv6_address_count = 1
  vpc_security_group_ids = ["${aws_security_group.network_sg.id}"]
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true

  root_block_device = [
    {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      volume_size           = module.bootstrap-node-config.disk-volume-size
      volume_type           = module.bootstrap-node-config.disk-volume-type
      throughput            = 250
      tags                  = {
        Name = "bootstrap-[count.index]-${var.network_name}-root-volume"
      }
    }
  ]

  tags = {
    Name       = "${var.network_name}-bootstrap-${count.index}"
    name       = "${var.network_name}-bootstrap-${count.index}"
    role       = "bootstrap node"
    os_name    = "ubuntu"
    os_version = "22.04"
    arch       = "x86_64"
  }

  depends_on = [
    aws_subnet.public_subnets,
    aws_internet_gateway.gw
  ]
}

module "bootstrap_node_evm" {
  source = "../../terraform/aws/ec2"

  count              = length(var.aws_region) * module.bootstrap-node-evm-config.instance-count
  ami                = data.aws_ami.ubuntu_amd64.image_id
  instance_type      = module.bootstrap-node-evm-config.instance-type
  subnet_id          = element(aws_subnet.public_subnets.*.id, 0)
  availability_zone  = var.azs
  ipv6_address_count = 1
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.network_sg.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  root_block_device = [
    {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      volume_size           = module.bootstrap-node-evm-config.disk-volume-size
      volume_type           = module.bootstrap-node-evm-config.disk-volume-type
      throughput            = 250
      tags                  = {
        Name = "bootstrap-evm-[count.index]-${var.network_name}-root-volume"
      }
    }
  ]

  tags = {
    Name       = "${var.network_name}-bootstrap-evm-${count.index}"
    name       = "${var.network_name}-bootstrap-evm-${count.index}"
    role       = "bootstrap node"
    os_name    = "ubuntu"
    os_version = "22.04"
    arch       = "x86_64"
  }

  depends_on = [
    aws_subnet.public_subnets,
    #aws_nat_gateway.nat_gateway,
    aws_internet_gateway.gw
  ]
}

module "full_node" {
  source = "../../terraform/aws/ec2"

  count              = length(var.aws_region) * module.full-node-config.instance-count
  ami                = data.aws_ami.ubuntu_amd64.image_id
  instance_type      = module.full-node-config.instance-type
  subnet_id          = element(aws_subnet.public_subnets.*.id, 0)
  availability_zone  = var.azs
  ipv6_address_count = 1
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.network_sg.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  root_block_device = [
    {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      volume_size           = module.full-node-config.disk-volume-size
      volume_type           = module.full-node-config.disk-volume-type
      throughput            = 250
      tags                  = {
        Name = "full-[count.index]-${var.network_name}-root-volume"
      }
    }
  ]

  tags = {
    Name       = "${var.network_name}-full-${count.index}"
    name       = "${var.network_name}-full-${count.index}"
    role       = "full node"
    os_name    = "ubuntu"
    os_version = "22.04"
    arch       = "x86_64"
  }

  depends_on = [
    aws_subnet.public_subnets,
    #aws_nat_gateway.nat_gateway,
    aws_internet_gateway.gw
  ]
}

module "rpc_node" {
  source = "../../terraform/aws/ec2"

  count              = length(var.aws_region) * module.rpc-node-config.instance-count
  ami                = data.aws_ami.ubuntu_amd64.image_id
  instance_type      = module.rpc-node-config.instance-type
  subnet_id          = element(aws_subnet.public_subnets.*.id, 0)
  availability_zone  = var.azs
  ipv6_address_count = 1
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.network_sg.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  root_block_device = [
    {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      volume_size           = module.rpc-node-config.disk-volume-size
      volume_type           = module.rpc-node-config.disk-volume-type
      throughput            = 250
      tags                  = {
        Name = "rpc-[count.index]-${var.network_name}-root-volume"
      }
    }
  ]
  tags = {
    Name       = "${var.network_name}-rpc-${count.index}"
    name       = "${var.network_name}-rpc-${count.index}"
    role       = "rpc node"
    os_name    = "ubuntu"
    os_version = "22.04"
    arch       = "x86_64"
  }

  depends_on = [
    aws_subnet.public_subnets,
    #aws_nat_gateway.nat_gateway,
    aws_internet_gateway.gw
  ]
}

module "domain_node" {
  source = "../../terraform/aws/ec2"

  count              = length(var.aws_region) * module.domain-node-config.instance-count
  ami                = data.aws_ami.ubuntu_amd64.image_id
  instance_type      = module.domain-node-config.instance-type
  subnet_id          = element(aws_subnet.public_subnets.*.id, 0)
  availability_zone  = var.azs
  ipv6_address_count = 1
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.network_sg.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  root_block_device = [
    {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      volume_size           = module.domain-node-config.disk-volume-size
      volume_type           = module.domain-node-config.disk-volume-type
      throughput            = 250
      tags                  = {
        Name = "domain-[count.index]-${var.network_name}-root-volume"
      }
    }
  ]
  tags = {
    Name       = "${var.network_name}-domain-${count.index}"
    name       = "${var.network_name}-domain-${count.index}"
    role       = "domain node"
    os_name    = "ubuntu"
    os_version = "22.04"
    arch       = "x86_64"
  }

  depends_on = [
    aws_subnet.public_subnets,
    #aws_nat_gateway.nat_gateway,
    aws_internet_gateway.gw
  ]
}

module "farmer_node" {
  source = "../../terraform/aws/ec2"

  count              = length(var.aws_region) * module.farmer-node-config.instance-count
  ami                = data.aws_ami.ubuntu_amd64.image_id
  instance_type      = module.farmer-node-config.instance-type
  subnet_id          = element(aws_subnet.public_subnets.*.id, 0)
  availability_zone  = var.azs
  ipv6_address_count = 1
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.network_sg.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  root_block_device = [
    {
      delete_on_termination = true
      encrypted             = true
      iops                  = 3000
      volume_size           = module.farmer-node-config.disk-volume-size
      volume_type           = module.farmer-node-config.disk-volume-type
      throughput            = 250
      tags                  = {
        Name = "farmer-[count.index]-${var.network_name}-root-volume"
      }
    }
  ]
  tags = {
    Name       = "${var.network_name}-farmer-${count.index}"
    name       = "${var.network_name}-farmer-${count.index}"
    role       = "farmer node"
    os_name    = "ubuntu"
    os_version = "22.04"
    arch       = "x86_64"
  }

  depends_on = [
    aws_subnet.public_subnets,
    #aws_nat_gateway.nat_gateway,
    aws_internet_gateway.gw
  ]
}
