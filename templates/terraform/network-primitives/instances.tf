resource "aws_instance" "bootstrap_node" {
  count              = length(var.aws_region) * var.bootstrap-node-config.instance-count
  ami                = data.aws_ami.ubuntu_amd64.image_id
  instance_type      = var.bootstrap-node-config.instance-type
  subnet_id          = element(aws_subnet.public_subnets.*.id, 0)
  availability_zone  = var.azs
  ipv6_address_count = 1
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.network_sg.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.bootstrap-node-config.disk-volume-size
    volume_type = var.bootstrap-node-config.disk-volume-type
    iops        = 3000
    throughput  = 250
  }


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
    #aws_nat_gateway.nat_gateway,
    aws_internet_gateway.gw
  ]

  lifecycle {

    ignore_changes = [ami, ipv6_address_count]

  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo apt update -y",
    ]

    on_failure = continue

  }

  # Setting up the ssh connection
  connection {
    type        = "ssh"
    host        = element(self.*.public_ip, count.index)
    user        = var.ssh_user
    private_key = file("${var.private_key_path}")
    timeout     = "300s"
  }

}

resource "aws_instance" "bootstrap_node_evm" {
  count              = length(var.aws_region) * var.bootstrap-node-evm-config.instance-count
  ami                = data.aws_ami.ubuntu_amd64.image_id
  instance_type      = var.bootstrap-node-evm-config.instance-type
  subnet_id          = element(aws_subnet.public_subnets.*.id, 0)
  availability_zone  = var.azs
  ipv6_address_count = 1
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.network_sg.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.bootstrap-node-config.disk-volume-size
    volume_type = var.bootstrap-node-config.disk-volume-type
    iops        = 3000
    throughput  = 250
  }


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

  lifecycle {

    ignore_changes = [ami, ipv6_address_count]

  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo apt update -y",
    ]

    on_failure = continue

  }

  # Setting up the ssh connection
  connection {
    type        = "ssh"
    host        = element(self.*.public_ip, count.index)
    user        = var.ssh_user
    private_key = file("${var.private_key_path}")
    timeout     = "300s"
  }

}

resource "aws_instance" "bootstrap_node_autoid" {
  count              = length(var.aws_region) * var.bootstrap-node-autoid-config.instance-count
  ami                = data.aws_ami.ubuntu_amd64.image_id
  instance_type      = var.bootstrap-node-autoid-config.instance-type
  subnet_id          = element(aws_subnet.public_subnets.*.id, 0)
  availability_zone  = var.azs
  ipv6_address_count = 1
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.network_sg.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.bootstrap-node-config.disk-volume-size
    volume_type = var.bootstrap-node-config.disk-volume-type
    iops        = 3000
    throughput  = 250
  }


  tags = {
    Name       = "${var.network_name}-bootstrap-autoid-${count.index}"
    name       = "${var.network_name}-bootstrap-autoid-${count.index}"
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

  lifecycle {

    ignore_changes = [ami, ipv6_address_count]

  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo apt update -y",
    ]

    on_failure = continue

  }

  # Setting up the ssh connection
  connection {
    type        = "ssh"
    host        = element(self.*.public_ip, count.index)
    user        = var.ssh_user
    private_key = file("${var.private_key_path}")
    timeout     = "300s"
  }

}

resource "aws_instance" "rpc_squid_node" {
  count              = length(var.aws_region) * var.rpc-squid-node-config.instance-count
  ami                = data.aws_ami.ubuntu_amd64.image_id
  instance_type      = var.rpc-squid-node-config.instance-type
  subnet_id          = element(aws_subnet.public_subnets.*.id, 0)
  availability_zone  = var.azs
  ipv6_address_count = 1
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.network_sg.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.rpc-squid-node-config.disk-volume-size
    volume_type = var.rpc-squid-node-config.disk-volume-type
    iops        = 3000
    throughput  = 250
  }

  tags = {
    Name       = "${var.network_name}-rpc-squid-${count.index}"
    name       = "${var.network_name}-rpc-squid-${count.index}"
    role       = "rpc-squid node"
    os_name    = "ubuntu"
    os_version = "22.04"
    arch       = "x86_64"
  }

  depends_on = [
    aws_subnet.public_subnets,
    #aws_nat_gateway.nat_gateway,
    aws_internet_gateway.gw
  ]

  lifecycle {

    ignore_changes = [ami, ipv6_address_count]

  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo apt update -y",
    ]

    on_failure = continue

  }

  # Setting up the ssh connection
  connection {
    type        = "ssh"
    host        = element(self.*.public_ip, count.index)
    user        = var.ssh_user
    private_key = file("${var.private_key_path}")
    timeout     = "300s"
  }

}

resource "aws_instance" "nova_squid_node" {
  count              = length(var.aws_region) * var.nova-squid-node-config.instance-count
  ami                = data.aws_ami.ubuntu_amd64.image_id
  instance_type      = var.nova-squid-node-config.instance-type
  subnet_id          = element(aws_subnet.public_subnets.*.id, 0)
  availability_zone  = var.azs
  ipv6_address_count = 1
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.network_sg.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.nova-squid-node-config.disk-volume-size
    volume_type = var.nova-squid-node-config.disk-volume-type
    iops        = 3000
    throughput  = 250
  }

  tags = {
    Name       = "${var.network_name}-nova-squid-${count.index}"
    name       = "${var.network_name}-nova-squid-${count.index}"
    role       = "nova-squid node"
    os_name    = "ubuntu"
    os_version = "22.04"
    arch       = "x86_64"
  }

  depends_on = [
    aws_subnet.public_subnets,
    #aws_nat_gateway.nat_gateway,
    aws_internet_gateway.gw
  ]

  lifecycle {

    ignore_changes = [ami, ipv6_address_count]

  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo apt update -y",
    ]

    on_failure = continue

  }

  # Setting up the ssh connection
  connection {
    type        = "ssh"
    host        = element(self.*.public_ip, count.index)
    user        = var.ssh_user
    private_key = file("${var.private_key_path}")
    timeout     = "300s"
  }

}

resource "aws_instance" "rpc_node" {
  count              = length(var.aws_region) * var.rpc-node-config.instance-count
  ami                = data.aws_ami.ubuntu_amd64.image_id
  instance_type      = var.rpc-node-config.instance-type
  subnet_id          = element(aws_subnet.public_subnets.*.id, 0)
  availability_zone  = var.azs
  ipv6_address_count = 1
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.network_sg.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.rpc-node-config.disk-volume-size
    volume_type = var.rpc-node-config.disk-volume-type
    iops        = 3000
    throughput  = 250
  }
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

  lifecycle {

    ignore_changes = [ami, ipv6_address_count]

  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo apt update -y",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install curl gnupg openssl net-tools -y",
    ]

    on_failure = continue

  }

  # Setting up the ssh connection
  connection {
    type        = "ssh"
    host        = element(self.*.public_ip, count.index)
    user        = var.ssh_user
    private_key = file("${var.private_key_path}")
    timeout     = "300s"
  }

}


resource "aws_instance" "domain_node" {
  count              = length(var.aws_region) * var.domain-node-config.instance-count
  ami                = data.aws_ami.ubuntu_amd64.image_id
  instance_type      = var.domain-node-config.instance-type
  subnet_id          = element(aws_subnet.public_subnets.*.id, 0)
  availability_zone  = var.azs
  ipv6_address_count = 1
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.network_sg.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.domain-node-config.disk-volume-size
    volume_type = var.domain-node-config.disk-volume-type
    iops        = 3000
    throughput  = 250
  }

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

  lifecycle {

    ignore_changes = [ami, ipv6_address_count]

  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo apt update -y",
    ]

    on_failure = continue

  }

  # Setting up the ssh connection
  connection {
    type        = "ssh"
    host        = element(self.*.public_ip, count.index)
    user        = var.ssh_user
    private_key = file("${var.private_key_path}")
    timeout     = "300s"
  }

}

resource "aws_instance" "autoid_node" {
  count              = length(var.aws_region) * var.autoid-node-config.instance-count
  ami                = data.aws_ami.ubuntu_amd64.image_id
  instance_type      = var.autoid-node-config.instance-type
  subnet_id          = element(aws_subnet.public_subnets.*.id, 0)
  availability_zone  = var.azs
  ipv6_address_count = 1
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.network_sg.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.autoid-node-config.disk-volume-size
    volume_type = var.autoid-node-config.disk-volume-type
    iops        = 3000
    throughput  = 250
  }

  tags = {
    Name       = "${var.network_name}-autoid-${count.index}"
    name       = "${var.network_name}-autoid-${count.index}"
    role       = "autoid node"
    os_name    = "ubuntu"
    os_version = "22.04"
    arch       = "x86_64"
  }

  depends_on = [
    aws_subnet.public_subnets,
    #aws_nat_gateway.nat_gateway,
    aws_internet_gateway.gw
  ]

  lifecycle {

    ignore_changes = [ami, ipv6_address_count]

  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo apt update -y",
    ]

    on_failure = continue

  }

  # Setting up the ssh connection
  connection {
    type        = "ssh"
    host        = element(self.*.public_ip, count.index)
    user        = var.ssh_user
    private_key = file("${var.private_key_path}")
    timeout     = "300s"
  }

}

resource "aws_instance" "farmer_node" {
  count              = length(var.aws_region) * var.farmer-node-config.instance-count
  ami                = data.aws_ami.ubuntu_amd64.image_id
  instance_type      = var.farmer-node-config.instance-type
  subnet_id          = element(aws_subnet.public_subnets.*.id, 0)
  availability_zone  = var.azs
  ipv6_address_count = 1
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.network_sg.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = var.farmer-node-config.disk-volume-size
    volume_type = var.farmer-node-config.disk-volume-type
    iops        = 3000
    throughput  = 250
  }
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

  lifecycle {

    ignore_changes = [ami, ipv6_address_count]

  }

  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo apt update -y",
    ]

    on_failure = continue

  }

  # Setting up the ssh connection
  connection {
    type        = "ssh"
    host        = element(self.*.public_ip, count.index)
    user        = var.ssh_user
    private_key = file("${var.private_key_path}")
    timeout     = "300s"
  }

}
