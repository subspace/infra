resource "null_resource" "setup-telemetry-server" {

  depends_on = [aws_instance.telemetry_subspace_node]

  connection {
    host           = aws_instance.telemetry_subspace_node.public_ip
    user           = var.ssh_user
    type           = "ssh"
    agent          = true
    agent_identity = var.aws_key_name
    private_key    = file("${var.private_key_path}")
    timeout        = "300s"
  }

  # create telemetry dir
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/telemetry",
      "sudo chown -R ${var.ssh_user}:${var.ssh_user} /home/${var.ssh_user}/telemetry/ && sudo chmod -R 750 /home/${var.ssh_user}/telemetry/"
    ]
  }

  # copy install file
  provisioner "file" {
    source      = "${var.path_to_scripts}/installer.sh"
    destination = "/home/${var.ssh_user}/telemetry/installer.sh"
  }

}


resource "null_resource" "start-telemetry-server" {

  depends_on = [null_resource.setup-telemetry-server]

  connection {
    host           = aws_instance.telemetry_subspace_node.public_ip
    user           = var.ssh_user
    type           = "ssh"
    agent          = true
    agent_identity = var.aws_key_name
    private_key    = file("${var.private_key_path}")
    timeout        = "300s"

  }

  # install deployments
  provisioner "remote-exec" {
    inline = [
      # install nginx, certbot, docker and docker compose
      "sudo bash /home/${var.ssh_user}/telemetry/installer.sh",
      # set hostname
      "sudo hostnamectl set-hostname telemetry-instance-1",
      # start systemd services
      "sudo systemctl daemon-reload",
      # start docker daemon
      "sudo systemctl enable --now docker.service",
      "https://github.com/autonomys/substrate-telemetry.git",
      "sudo docker compose -f /home/${var.ssh_user}/substrate-telemetry/docker-compose.yml up -d",
      "echo 'Installation Complete'",
    ]
  }

}
