#Linux x86_64 runner
resource "aws_instance" "linux_x86_64_runner" {
  count             = length(var.public_subnet_cidrs)
  ami               = data.aws_ami.ubuntu_x86_64.image_id
  instance_type     = element(var.instance_type, 1)
  subnet_id         = element(aws_subnet.public_subnets.*.id, count.index)
  availability_zone = element(var.azs, count.index)
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.allow_runner.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true

  tags = {
    name       = "gh-linux-x86-64-runner"
    role       = "runner"
    os_name    = "ubuntu"
    os_version = "22.04"
    arch       = "x86_64"
  }

  depends_on = [
    aws_subnet.public_subnets,
    aws_nat_gateway.nat_gateway,
    aws_internet_gateway.gw
  ]

  lifecycle {

    create_before_destroy = true

  }

  provisioner "file" {
    source      = "./scripts/secure.sh"
    destination = "/home/ubuntu/secure.sh"
  }

  provisioner "file" {
    source      = "./scripts/cleanup.sh"
    destination = "/home/ubuntu/cleanup.sh"
  }

  # # Github runner installation
  provisioner "remote-exec" {
    inline = [
      "sleep 60",
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt update -y",
      "sudo apt upgrade -y",
      "sudo apt install git curl wget gnupg openssl net-tools -y",
      # Download runner image
      "mkdir actions-runner && cd actions-runner",
      "curl -o actions-runner-linux-x64-${var.gh_runner_version}.tar.gz -L https://github.com/actions/runner/releases/download/v${var.gh_runner_version}/actions-runner-linux-x64-${var.gh_runner_version}.tar.gz",
      "echo '${lookup(var.gh_runner_checksums, "linux_x86_64", "")} actions-runner-linux-x64-${var.gh_runner_version}.tar.gz' | shasum -a 256 -c",
      "tar xzf ./actions-runner-linux-x64-${var.gh_runner_version}.tar.gz",
      # configure runner
      "./config.sh --url https://github.com/subspace --token ${var.gh_token} --unattended --name linux_x86_64 --labels 'self-hosted,Linux,x86_64' --work _work --runasservice",
      "sudo ./svc.sh install",
      "sudo ./svc.sh start",
      "sudo ./svc.sh status",
      # install monitoring
      "sudo wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh --non-interactive --nightly-channel --claim-rooms ${var.netdata_room} --claim-token ${var.netdata_token} --claim-url https://app.netdata.cloud",

    ]

    on_failure = continue

  }

  # Setting up the ssh connection
  connection {
    type        = "ssh"
    host        = element(self.*.public_ip, count.index)
    user        = "ubuntu"
    private_key = file("${var.public_key_path}")
    timeout     = "90s"
  }

}

resource "aws_instance" "linux_arm64_runner" {
  count             = length(var.public_subnet_cidrs)
  ami               = data.aws_ami.ubuntu_arm64.image_id
  instance_type     = element(var.instance_type_arm, 0)
  subnet_id         = element(aws_subnet.public_subnets.*.id, count.index)
  availability_zone = element(var.azs, count.index)
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.allow_runner.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true

  tags = {
    name       = "gh-linux-arm64-runner"
    role       = "runner"
    os_name    = "ubuntu"
    os_version = "22.04"
    arch       = "arm64"
  }

  depends_on = [
    aws_subnet.public_subnets,
    aws_nat_gateway.nat_gateway,
    aws_internet_gateway.gw
  ]

  lifecycle {

    create_before_destroy = true

  }

  provisioner "file" {
    source      = "./scripts/secure.sh"
    destination = "/home/ubuntu/secure.sh"
  }

  provisioner "file" {
    source      = "./scripts/cleanup.sh"
    destination = "/home/ubuntu/cleanup.sh"
  }

  # Github runner installation
  provisioner "remote-exec" {
    inline = [
      "sleep 120",
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo apt update -y",
      "sudo apt upgrade -y",
      "sudo apt install git curl wget gnupg openssl net-tools -y",
      # Download runner image
      "mkdir actions-runner && cd actions-runner",
      "curl -o actions-runner-linux-arm64-${var.gh_runner_version}.tar.gz -L https://github.com/actions/runner/releases/download/v${var.gh_runner_version}/actions-runner-linux-arm64-${var.gh_runner_version}.tar.gz",
      "echo '${lookup(var.gh_runner_checksums, "linux_arm64", "")} actions-runner-linux-arm64-${var.gh_runner_version}.tar.gz' | shasum -a 256 -c",
      "tar xzf ./actions-runner-linux-arm64-${var.gh_runner_version}.tar.gz",
      # configure runner
      "./config.sh --url https://github.com/subspace --token ${var.gh_token} --unattended --name linux_arm64 --labels 'self-hosted,Linux,ARM64' --work _work --runasservice",
      "sudo ./svc.sh install",
      "sudo ./svc.sh start",
      "sudo ./svc.sh status",
      # install monitoring
      "sudo wget -O /tmp/netdata-kickstart.sh https://my-netdata.io/kickstart.sh && sh /tmp/netdata-kickstart.sh --non-interactive --nightly-channel --claim-rooms ${var.netdata_room} --claim-token ${var.netdata_token} --claim-url https://app.netdata.cloud",
    ]

    on_failure = continue

  }

  # Setting up the ssh connection
  connection {
    type        = "ssh"
    host        = element(self.*.public_ip, count.index)
    user        = "ubuntu"
    private_key = file("${var.public_key_path}")
    timeout     = "90s"
  }
}

resource "aws_instance" "mac_x86_64_runner" {
  count             = length(var.public_subnet_cidrs)
  ami               = data.aws_ami.mac_x86_64.image_id
  instance_type     = element(var.instance_type_mac, 0)
  subnet_id         = element(aws_subnet.public_subnets.*.id, count.index)
  availability_zone = element(var.azs, count.index)
  tenancy           = "host"
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.allow_runner.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true

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
    aws_nat_gateway.nat_gateway,
    aws_internet_gateway.gw
  ]

  lifecycle {

    create_before_destroy = true

  }

  provisioner "file" {
    source      = "./scripts/secure.sh"
    destination = "/home/ec2-user/secure.sh"
  }

  provisioner "file" {
    source      = "./scripts/cleanup.sh"
    destination = "/home/ec2-user/cleanup.sh"
  }

  # Github runner installation
  provisioner "remote-exec" {
    inline = [
      "sleep 160",
      "mkdir actions-runner && cd actions-runner",
      "curl -o actions-runner-osx-x64-${var.gh_runner_version}.tar.gz -L https://github.com/actions/runner/releases/download/v${var.gh_runner_version}/actions-runner-osx-x64-${var.gh_runner_version}.tar.gz",
      "echo '${lookup(var.gh_runner_checksums, "mac_x86_64", "")} actions-runner-osx-x64-${var.gh_runner_version}.tar.gz' | shasum -a 256 -c",
      "tar xzf ./actions-runner-osx-x64-${var.gh_runner_version}.tar.gz",
      "./config.sh --url https://github.com/subspace --token ${var.gh_token} --unattended --name mac_x86_64 --labels 'self-hosted,MacOS,x86_64' --work _work --runasservice",
      "sudo ./run.sh",
      "curl https://my-netdata.io/kickstart.sh > /tmp/netdata-kickstart.sh && sh /tmp/netdata-kickstart.sh --non-interactive --nightly-channel --claim-rooms ${var.netdata_room} --claim-token ${var.netdata_token} --claim-url https://app.netdata.cloud",
    ]

    on_failure = continue

  }

  # Setting up the ssh connection to install the runner server
  connection {
    type        = "ssh"
    host        = element(self.*.public_ip, count.index)
    user        = "ec2-user"
    private_key = file("${var.public_key_path}")
    timeout     = "90s"
  }

}


resource "aws_instance" "mac_arm64_runner" {
  count             = length(var.public_subnet_cidrs)
  ami               = data.aws_ami.mac_arm64.image_id
  instance_type     = element(var.instance_type_mac, 1)
  subnet_id         = element(aws_subnet.public_subnets.*.id, count.index)
  availability_zone = element(var.azs, count.index)
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.allow_runner.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true
  tenancy                     = "host"

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
    aws_nat_gateway.nat_gateway,
    aws_internet_gateway.gw
  ]

  lifecycle {

    create_before_destroy = true

  }

  provisioner "file" {
    source      = "./scripts/secure.sh"
    destination = "/home/ec2-user/secure.sh"
  }

  provisioner "file" {
    source      = "./scripts/cleanup.sh"
    destination = "/home/ec2-user/cleanup.sh"
  }

  # Github runner installation
  provisioner "remote-exec" {
    inline = [
      "sleep 160",
      "mkdir actions-runner && cd actions-runner",
      "curl -o actions-runner-osx-x64-${var.gh_runner_version}.tar.gz -L https://github.com/actions/runner/releases/download/v${var.gh_runner_version}/actions-runner-osx-arm64-${var.gh_runner_version}.tar.gz",
      "echo '${lookup(var.gh_runner_checksums, "mac_arm64", "")}  actions-runner-osx-arm64-${var.gh_runner_version}.tar.gz' | shasum -a 256 -c",
      "tar xzf ./actions-runner-osx-arm64-${var.gh_runner_version}.tar.gz",
      "./config.sh --url https://github.com/subspace --token ${var.gh_token} --unattended --name mac_arm64 --labels 'self-hosted,MacOS,ARM64' --work _work --runasservice",
      "sudo ./run.sh",
      "curl https://my-netdata.io/kickstart.sh > /tmp/netdata-kickstart.sh && sh /tmp/netdata-kickstart.sh --non-interactive --nightly-channel --claim-rooms ${var.netdata_room}  --claim-token ${var.netdata_token} --claim-url https://app.netdata.cloud",
    ]

    on_failure = continue

  }

  # Setting up the ssh connection to install the runner server
  connection {
    type        = "ssh"
    host        = element(self.*.public_ip, count.index)
    user        = "ec2-user"
    private_key = file("${var.public_key_path}")
    timeout     = "90s"
  }

}


resource "aws_instance" "windows_x86_64_runner" {
  count             = length(var.public_subnet_cidrs)
  ami               = data.aws_ami.windows_x86_64.image_id
  instance_type     = element(var.instance_type, 1)
  subnet_id         = element(aws_subnet.public_subnets.*.id, count.index)
  availability_zone = element(var.azs, count.index)
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.allow_runner.id}"]
  # the Public SSH key
  key_name                    = var.aws_key_name
  associate_public_ip_address = true

  tags = {
    name       = "gh-windows-runner"
    role       = "runner"
    os_name    = "windows"
    os_version = "Microsoft Windows Server 2022 "
    arch       = "x86_64"
  }

  depends_on = [
    aws_subnet.public_subnets,
    aws_nat_gateway.nat_gateway,
    aws_internet_gateway.gw
  ]

  user_data = <<-EOT
    <powershell>
    Enable-PSRemoting -Force
    Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -RemoteAddress "0.0.0.0/0"
    Set-ItemProperty -Path 'HKLM:\\System\\CurrentControlSet\\Control\\Terminal Server' -Name 'fDenyTSConnections' -Value 0
    Enable-NetFirewallRule -DisplayGroup 'Remote Desktop'

    # Set the administrator password using EC2Launch module
    $ec2LaunchConfigPath = "C:\\ProgramData\\Amazon\\EC2-Windows\\Launch\\Config\\LaunchConfig.json"
    $config = Get-Content -Path $ec2LaunchConfigPath -Raw | ConvertFrom-Json
    $config.Images[0].Password = "${var.win_admin_password}" | ConvertTo-SecureString -AsPlainText -Force
    $config.Images[0].Ec2SetPassword = $true
    $config | ConvertTo-Json | Set-Content -Path $ec2LaunchConfigPath
    </powershell>
  EOT

  lifecycle {

    create_before_destroy = true

  }

  # Github runner installation
  provisioner "remote-exec" {
    inline = [
      # Download runner image
      "mkdir actions-runner; cd actions-runner",
      "Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v${var.gh_runner_version}/actions-runner-win-x64-${var.gh_runner_version}.zip -OutFile actions-runner-win-x64-${var.gh_runner_version}.zip",
      "if((Get-FileHash -Path actions-runner-win-x64-${var.gh_runner_version}.zip -Algorithm SHA256).Hash.ToUpper() -ne '${lookup(var.gh_runner_checksums, "windows_x86_64", "")}'.ToUpper()){ throw 'Computed checksum did not match' }",
      "Add-Type -AssemblyName System.IO.Compression.FileSystem ; [System.IO.Compression.ZipFile]::ExtractToDirectory(\"$PWD/actions-runner-win-x64-${var.gh_runner_version}.zip\", \"$PWD\")",
      # configure runner
      "./config.cmd --url https://github.com/subspace --token ${var.gh_token} --unattended --name windows_x86_64 --labels 'self-hosted,Windows,x86_64' --work _work --runasservice",
      "./run.cmd",
    ]

    on_failure = continue
  }

  connection {
    type     = "winrm"
    user     = var.win_admin_username
    password = var.win_admin_password
    host     = element(self.*.public_ip, count.index)
    port     = 5985
    timeout  = "10m"
    use_ntlm = true
    insecure = true
  }
}
