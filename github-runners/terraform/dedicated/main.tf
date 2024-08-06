#Linux x86_64 runner
resource "aws_instance" "linux_x86_64_runner" {
  count             = length(var.public_subnet_cidrs)
  ami               = data.aws_ami.ubuntu_x86_64.image_id
  instance_type     = element(var.instance_type, 0)
  subnet_id         = element(aws_subnet.public_subnets.*.id, count.index)
  availability_zone = var.azs
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.allow_runner.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = "100"
    volume_type = "gp3"
    iops        = 3000
    throughput  = 250
  }

  tags = {
    name       = "gh-linux-x86-64-runner"
    role       = "runner"
    os_name    = "ubuntu"
    os_version = "20.04"
    arch       = "x86_64"
  }

  depends_on = [
    aws_subnet.public_subnets,
    aws_internet_gateway.gw
  ]

  lifecycle {

    create_before_destroy = true

  }

  # # Github runner installation
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt update -y",
      "sudo apt upgrade -y",
      "sudo apt install make build-essential openssl gnupg gcc protobuf-compiler clang lldb lld unzip pkg-config libssl-dev jq ca-certificates --no-install-recommends -y",
      "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly -y",
      "source \"$HOME/.cargo/env\"",
      # Download runner image
      "mkdir actions-runner && cd actions-runner",
      "curl -o actions-runner-linux-x64-${var.gh_runner_version}.tar.gz -L https://github.com/actions/runner/releases/download/v${var.gh_runner_version}/actions-runner-linux-x64-${var.gh_runner_version}.tar.gz",
      "echo '${lookup(var.gh_runner_checksums, "linux_x86_64", "")} actions-runner-linux-x64-${var.gh_runner_version}.tar.gz' | shasum -a 256 -c",
      "tar xzf ./actions-runner-linux-x64-${var.gh_runner_version}.tar.gz",
      # configure runner
      "echo 'ACTIONS_RUNNER_HOOK_JOB_COMPLETED=/home/${var.ssh_user[0]}/cleanup_script.sh' > .env",
      "./config.sh --url https://github.com/autonomys --token ${var.gh_token} --unattended --name ubuntu-20.04-x86-64 --labels 'self-hosted,ubuntu-20.04-x86-64,Linux,x86-64' --work _work --runasservice",
      "sudo ./svc.sh install ${var.ssh_user[0]}",
      "sudo ./svc.sh start",
      # install monitoring
      "sudo sh -c \"curl https://my-netdata.io/kickstart.sh > /tmp/netdata-kickstart.sh && sh /tmp/netdata-kickstart.sh --non-interactive --nightly-channel --claim-rooms ${var.netdata_room} --claim-token ${var.netdata_token} --claim-url https://app.netdata.cloud\"",

    ]

    on_failure = continue

  }

  # Setting up the ssh connection
  connection {
    type        = "ssh"
    host        = element(self.*.public_ip, count.index)
    user        = var.ssh_user[0]
    private_key = file("${var.private_key_path}")
    timeout     = "90s"
  }

}

resource "aws_instance" "linux_arm64_runner" {
  count             = length(var.public_subnet_cidrs)
  ami               = data.aws_ami.ubuntu_arm64.image_id
  instance_type     = element(var.instance_type_arm, 0)
  subnet_id         = element(aws_subnet.public_subnets.*.id, count.index)
  availability_zone = var.azs
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.allow_runner.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = "100"
    volume_type = "gp3"
    iops        = 3000
    throughput  = 250
  }

  tags = {
    name       = "gh-linux-arm64-runner"
    role       = "runner"
    os_name    = "ubuntu"
    os_version = "20.04"
    arch       = "arm64"
  }

  depends_on = [
    aws_subnet.public_subnets,
    aws_internet_gateway.gw
  ]

  lifecycle {

    create_before_destroy = true

  }

  # Github runner installation
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt update -y",
      "sudo apt upgrade -y",
      "sudo apt install make build-essential openssl gnupg gcc protobuf-compiler clang lldb lld unzip pkg-config libssl-dev jq ca-certificates --no-install-recommends -y",
      "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly -y",
      "source \"$HOME/.cargo/env\"",
      # Download runner image
      "mkdir actions-runner && cd actions-runner",
      "curl -o actions-runner-linux-arm64-${var.gh_runner_version}.tar.gz -L https://github.com/actions/runner/releases/download/v${var.gh_runner_version}/actions-runner-linux-arm64-${var.gh_runner_version}.tar.gz",
      "echo '${lookup(var.gh_runner_checksums, "linux_arm64", "")} actions-runner-linux-arm64-${var.gh_runner_version}.tar.gz' | shasum -a 256 -c",
      "tar xzf ./actions-runner-linux-arm64-${var.gh_runner_version}.tar.gz",
      # configure runner
      "echo 'ACTIONS_RUNNER_HOOK_JOB_COMPLETED=/home/${var.ssh_user[0]}/cleanup_script.sh' > .env",
      "./config.sh --url https://github.com/autonomys --token ${var.gh_token} --unattended --name ubuntu-20.04-arm64 --labels 'self-hosted,ubuntu-20.04-arm64,Linux,arm64' --work _work --runasservice",
      "sudo ./svc.sh install ${var.ssh_user[0]}",
      "sudo ./svc.sh start",
      # install monitoring
      "sudo sh -c \"curl https://my-netdata.io/kickstart.sh > /tmp/netdata-kickstart.sh && sh /tmp/netdata-kickstart.sh --non-interactive --nightly-channel --claim-rooms ${var.netdata_room} --claim-token ${var.netdata_token} --claim-url https://app.netdata.cloud\"",
    ]

    on_failure = continue

  }

  # Setting up the ssh connection
  connection {
    type        = "ssh"
    host        = element(self.*.public_ip, count.index)
    user        = var.ssh_user[0]
    private_key = file("${var.private_key_path}")
    timeout     = "90s"
  }
}

resource "aws_instance" "mac_x86_64_runner" {
  count             = length(var.public_subnet_cidrs)
  ami               = data.aws_ami.mac_x86_64.image_id
  instance_type     = element(var.instance_type_mac, 0)
  subnet_id         = element(aws_subnet.public_subnets.*.id, count.index)
  availability_zone = var.azs
  tenancy           = "host"
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.allow_runner.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = "100"
    volume_type = "gp3"
    iops        = 3000
    throughput  = 250
  }

  tags = {
    name       = "gh-macos-x86-runner"
    role       = "runner"
    os_name    = "macos"
    os_version = "12"
    os_name    = "Monterey"
    arch       = "x86_64"
  }

  depends_on = [
    aws_subnet.public_subnets,
    aws_internet_gateway.gw
  ]

  lifecycle {

    create_before_destroy = true

  }

  # Github runner installation
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "mkdir actions-runner && cd actions-runner",
      "curl -o actions-runner-osx-x64-${var.gh_runner_version}.tar.gz -L https://github.com/actions/runner/releases/download/v${var.gh_runner_version}/actions-runner-osx-x64-${var.gh_runner_version}.tar.gz",
      "echo '${lookup(var.gh_runner_checksums, "mac_x86_64", "")} actions-runner-osx-x64-${var.gh_runner_version}.tar.gz' | shasum -a 256 -c",
      "tar xzf ./actions-runner-osx-x64-${var.gh_runner_version}.tar.gz",
      "echo 'ACTIONS_RUNNER_HOOK_JOB_COMPLETED=/home/${var.ssh_user[1]}/cleanup_script.sh' > .env",
      "./config.sh --url https://github.com/autonomys --token ${var.gh_token} --unattended --name macos-12-x86-64 --labels 'self-hosted,macos-12-x86-64,macOS,x86-64' --work _work --runasservice",
      "sudo su -- ${var.ssh_user[1]} ./svc.sh install",
      "sudo su -- ${var.ssh_user[1]} ./runsvc.sh start &",
      # install monitoring
      "NONINTERACTIVE=1 /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)\"",
      "brew install netdata protobuf jq yq",
      "xcode-select --install",
      "softwareupdate --install-rosetta",
      "softwareupdate -i -r",
      "netdata -W \"claim -token=${var.netdata_token} -rooms=${var.netdata_room}\" -u ${var.ssh_user[1]} -c /opt/homebrew/var/lib/netdata/cloud.d/cloud.conf",
      "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly -y",
      "source \"$HOME/.cargo/env\"",
    ]

    on_failure = continue

  }

  # Setting up the ssh connection to install the runner server
  connection {
    type        = "ssh"
    host        = element(self.*.public_ip, count.index)
    user        = var.ssh_user[1]
    private_key = file("${var.private_key_path}")
    timeout     = "90s"
  }

}

resource "aws_instance" "mac_arm64_runner" {
  count             = length(var.public_subnet_cidrs)
  ami               = data.aws_ami.mac_arm64.image_id
  instance_type     = element(var.instance_type_mac, 1)
  subnet_id         = element(aws_subnet.public_subnets.*.id, count.index)
  availability_zone = var.azs
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.allow_runner.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  tenancy                     = "host"
  ebs_optimized               = true
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = "100"
    volume_type = "gp3"
    iops        = 3000
    throughput  = 250
  }
  tags = {
    name       = "gh-macos-arm64-runner"
    role       = "runner"
    os_name    = "macos"
    os_version = "12"
    os_name    = "Monterey"
    arch       = "arm64"
  }

  depends_on = [
    aws_subnet.public_subnets,
    aws_internet_gateway.gw
  ]

  lifecycle {

    create_before_destroy = true

  }

  # Github runner installation
  provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "mkdir actions-runner && cd actions-runner",
      "curl -o actions-runner-osx-x64-${var.gh_runner_version}.tar.gz -L https://github.com/actions/runner/releases/download/v${var.gh_runner_version}/actions-runner-osx-arm64-${var.gh_runner_version}.tar.gz",
      "echo '${lookup(var.gh_runner_checksums, "mac_arm64", "")}  actions-runner-osx-arm64-${var.gh_runner_version}.tar.gz' | shasum -a 256 -c",
      "tar xzf ./actions-runner-osx-arm64-${var.gh_runner_version}.tar.gz",
      "echo 'ACTIONS_RUNNER_HOOK_JOB_COMPLETED=/home/${var.ssh_user[1]}/cleanup_script.sh' > .env",
      "./config.sh --url https://github.com/autonomys --token ${var.gh_token} --unattended --name macos-12-arm64 --labels 'self-hosted,macos-12-arm64,macOS,arm64' --work _work --runasservice",
      "sudo su -- ${var.ssh_user[1]} ./svc.sh install",
      "sudo su -- ${var.ssh_user[1]} ./runsvc.sh start &",
      # install monitoring
      "NONINTERACTIVE=1 /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)\"",
      "brew install netdata protobuf jq yq",
      "xcode-select --install",
      "softwareupdate --install-rosetta",
      "softwareupdate -i -r",
      "netdata -W \"claim -token=${var.netdata_token} -rooms=${var.netdata_room}\" -u ${var.ssh_user[1]} -c /opt/homebrew/var/lib/netdata/cloud.d/cloud.conf",
      "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain nightly -y",
      "source \"$HOME/.cargo/env\"",
    ]

    on_failure = continue

  }

  # Setting up the ssh connection to install the runner server
  connection {
    type        = "ssh"
    host        = element(self.*.public_ip, count.index)
    user        = var.ssh_user[1]
    private_key = file("${var.private_key_path}")
    timeout     = "90s"
  }

}


resource "aws_instance" "windows_x86_64_runner" {
  count             = length(var.public_subnet_cidrs)
  ami               = data.aws_ami.windows_x86_64.image_id
  instance_type     = element(var.instance_type, 1)
  subnet_id         = element(aws_subnet.public_subnets.*.id, count.index)
  availability_zone = var.azs
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.allow_runner.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  ebs_optimized               = true
  ebs_block_device {
    device_name = "/dev/sda1"
    volume_size = "100"
    volume_type = "gp3"
    iops        = 3000
    throughput  = 250
  }

  tags = {
    name       = "gh-windows-runner"
    role       = "runner"
    os_name    = "windows"
    os_version = "Microsoft Windows Server 2022 "
    arch       = "x86_64"
  }

  depends_on = [
    aws_subnet.public_subnets,
    aws_internet_gateway.gw
  ]

  lifecycle {

    create_before_destroy = true

  }
}
