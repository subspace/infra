locals {
  blockscout_node_ip_v4 = flatten([
    [aws_instance.blockscout_node.*.public_ip],
    ]
  )
}

resource "null_resource" "setup-blockscout-node" {
  count = length(local.blockscout_node_ip_v4)

  depends_on = [aws_security_group.gemini-squid-sg, cloudflare_record.archive]

  # trigger on node ip changes
  triggers = {
    cluster_instance_ipv4s = join(",", local.blockscout_node_ip_v4)
  }

  connection {
    host           = local.blockscout_node_ip_v4[count.index]
    user           = var.ssh_user
    type           = "ssh"
    agent          = true
    agent_identity = var.aws_key_name
    private_key    = file("${var.private_key_path}")
    timeout        = "300s"
  }

  # clone and checkout blockscout repository
  provisioner "remote-exec" {
    inline = [
      "git clone https://github.com/autonomys/blockscout-backend.git",
      "cd blockscout-backend",
      #"git checkout gemini-3h-blockscout",
    ]
  }

  # copy docker install file
  provisioner "file" {
    source      = "${var.path_to_scripts}/install_docker.sh"
    destination = "/home/${var.ssh_user}/install_docker.sh"
  }

  provisioner "file" {
    source      = "${var.path_to_configs}/nginx-blockscout.conf"
    destination = "/home/${var.ssh_user}/backend.conf"
  }
  provisioner "file" {
    source      = "${var.path_to_configs}/cors-settings.conf"
    destination = "/home/${var.ssh_user}/cors-settings.conf"
  }

  # copy nginx install file
  provisioner "file" {
    source      = "${var.path_to_scripts}/install_nginx.sh"
    destination = "/home/${var.ssh_user}/install_nginx.sh"
  }

}

resource "null_resource" "start-blockscout-node" {
  count = length(local.blockscout_node_ip_v4)

  depends_on = [null_resource.setup-blockscout-node]

  # trigger on node deployment environment change
  triggers = {
    deployment_version = var.nova-blockscout-node-config.deployment-version
  }

  connection {
    host           = local.blockscout_node_ip_v4[count.index]
    user           = var.ssh_user
    type           = "ssh"
    agent          = true
    agent_identity = var.aws_key_name
    private_key    = file("${var.private_key_path}")
    timeout        = "300s"
  }

  # install nginx, certbot, docker and docker compose
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.ssh_user}/install_docker.sh",
      "sudo bash /home/${var.ssh_user}/install_docker.sh",
      # install nginx
      "chmod +x /home/${var.ssh_user}/install_nginx.sh",
      "sudo bash /home/${var.ssh_user}/install_nginx.sh",
    ]
  }

  # install deployments
  provisioner "remote-exec" {
    inline = [
      # copy files
      "sudo cp -f /home/${var.ssh_user}/cors-settings.conf /etc/nginx/cors-settings.conf",
      "sed -i -e 's/server_name _/server_name ${var.nova-blockscout-node-config.domain-prefix}.subspace.network/g' /home/${var.ssh_user}/backend.conf",
      "sudo cp -f /home/${var.ssh_user}/backend.conf /etc/nginx/backend.conf",
      # start systemd services
      "sudo systemctl daemon-reload",
      # start nginx
      "sudo systemctl enable --now nginx",
      "sudo systemctl start nginx",
      # install certbot & generate domain
      "sudo certbot --nginx --non-interactive -v --agree-tos -m alerts@subspace.network -d ${var.nova-blockscout-node-config.domain-prefix}.subspace.network",
      "sudo systemctl restart nginx",
      # set hostname
      "sudo hostnamectl set-hostname ${var.nova-blockscout-node-config.domain-prefix}-blockscout-${var.network_name}",
      # start docker daemon
      "sudo systemctl enable --now docker.service",
      "sudo systemctl restart docker.service",
      #"sudo docker compose -f /home/${var.ssh_user}/blockscout-backend/docker-compose/docker-compose-no-build-external-frontend.yml up -d",
      "echo 'Installation Complete'"
    ]
  }
}
