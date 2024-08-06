locals {
  bootstrap_nodes_ip_v4 = flatten([
    [aws_instance.bootstrap_node.*.public_ip]
    ]
  )
}

resource "null_resource" "setup-bootstrap-nodes" {
  count = length(local.bootstrap_nodes_ip_v4)

  depends_on = [aws_instance.bootstrap_node]

  # trigger on node ip changes
  triggers = {
    cluster_instance_ipv4s = join(",", local.bootstrap_nodes_ip_v4)
  }

  connection {
    host        = local.bootstrap_nodes_ip_v4[count.index]
    user        = var.ssh_user
    type        = "ssh"
    agent       = true
    private_key = file("${var.private_key_path}")
    timeout     = "300s"
  }

  # create subspace dir
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /home/${var.ssh_user}/subspace/",
      "sudo chown -R ${var.ssh_user}:${var.ssh_user} /home/${var.ssh_user}/subspace/ && sudo chmod -R 750 /home/${var.ssh_user}/subspace/"
    ]
  }

  # copy install file
  provisioner "file" {
    source      = "${var.path_to_scripts}/installer.sh"
    destination = "/home/${var.ssh_user}/subspace/installer.sh"
  }

  # install docker and docker compose
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.ssh_user}/subspace/installer.sh",
      "sudo bash /home/${var.ssh_user}/subspace/installer.sh",
    ]
  }

  # clone testing branch
  provisioner "remote-exec" {
    inline = [
      "cd /home/${var.ssh_user}/subspace/",
      "git clone https://github.com/autonomys/subspace.git",
      "cd subspace",
      "git checkout ${var.branch_name}"
    ]
  }

}

resource "null_resource" "prune-bootstrap-nodes" {
  count      = var.bootstrap-node-config.prune ? length(local.bootstrap_nodes_ip_v4) : 0
  depends_on = [null_resource.setup-bootstrap-nodes]

  triggers = {
    prune = var.bootstrap-node-config.prune
  }

  connection {
    host        = local.bootstrap_nodes_ip_v4[count.index]
    user        = var.ssh_user
    type        = "ssh"
    agent       = true
    private_key = file("${var.private_key_path}")
    timeout     = "300s"
  }

  provisioner "file" {
    source      = "${var.path_to_scripts}/prune_docker_system.sh"
    destination = "/home/${var.ssh_user}/subspace/prune_docker_system.sh"
  }

  # prune network
  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.ssh_user}/subspace/prune_docker_system.sh",
      "sudo bash /home/${var.ssh_user}/subspace/prune_docker_system.sh"
    ]
  }
}

resource "null_resource" "start-boostrap-nodes" {
  count = length(local.bootstrap_nodes_ip_v4)

  depends_on = [null_resource.setup-bootstrap-nodes]

  # trigger on node deployment version change
  triggers = {
    deployment_version = var.bootstrap-node-config.deployment-version
    reserved_only      = var.bootstrap-node-config.reserved-only
  }

  connection {
    host        = local.bootstrap_nodes_ip_v4[count.index]
    user        = var.ssh_user
    type        = "ssh"
    agent       = true
    private_key = file("${var.private_key_path}")
    timeout     = "300s"
  }

  # copy bootstrap node keys file
  provisioner "file" {
    source      = "./bootstrap_node_keys.txt"
    destination = "/home/${var.ssh_user}/subspace/node_keys.txt"
  }

  # copy DSN bootstrap node keys file
  provisioner "file" {
    source      = "./dsn_bootstrap_node_keys.txt"
    destination = "/home/${var.ssh_user}/subspace/dsn_bootstrap_node_keys.txt"
  }

  # copy compose file creation script
  provisioner "file" {
    source      = "${var.path_to_scripts}/create_bootstrap_node_compose_file.sh"
    destination = "/home/${var.ssh_user}/subspace/create_compose_file.sh"
  }

  # start docker containers
  provisioner "remote-exec" {
    inline = [
      # set hostname
      "sudo hostnamectl set-hostname ${var.network_name}-bootstrap-node-${count.index}",

      # create .env file
      "echo REPO_ORG=${var.bootstrap-node-config.repo-org} > /home/${var.ssh_user}/subspace/.env",
      "echo DOCKER_TAG=${var.bootstrap-node-config.docker-tag} >> /home/${var.ssh_user}/subspace/.env",
      "echo NETWORK_NAME=${var.network_name} >> /home/${var.ssh_user}/subspace/.env",
      "echo NODE_ID=${count.index} >> /home/${var.ssh_user}/subspace/.env",
      "echo NODE_KEY=$(sed -nr 's/NODE_${count.index}_KEY=//p' /home/${var.ssh_user}/subspace/node_keys.txt) >> /home/${var.ssh_user}/subspace/.env",
      "echo PIECE_CACHE_SIZE=${var.piece_cache_size} >> /home/${var.ssh_user}/subspace/.env",
      "echo DSN_NODE_ID=${count.index} >> /home/${var.ssh_user}/subspace/.env",
      "echo DSN_NODE_KEY=$(sed -nr 's/NODE_${count.index}_SUBSPACE_KEY=//p' /home/${var.ssh_user}/subspace/dsn_bootstrap_node_keys.txt) >> /home/${var.ssh_user}/subspace/.env",
      "echo DSN_LISTEN_PORT=${var.bootstrap-node-config.dsn-listen-port} >> /home/${var.ssh_user}/subspace/.env",
      "echo NODE_DSN_PORT=${var.bootstrap-node-config.node-dsn-port} >> /home/${var.ssh_user}/subspace/.env",
      "echo GENESIS_HASH=${var.bootstrap-node-config.genesis-hash} >> /home/${var.ssh_user}/subspace/.env",

      # create docker compose file
      "chmod +x /home/${var.ssh_user}/subspace/create_compose_file.sh",
      "bash /home/${var.ssh_user}/subspace/create_compose_file.sh ${var.bootstrap-node-config.reserved-only} ${length(local.bootstrap_nodes_ip_v4)} ${count.index}",

      # start subspace bootstrap node
      "cp -f /home/${var.ssh_user}/subspace/.env /home/${var.ssh_user}/subspace/subspace/.env",
      "sudo docker compose -f /home/${var.ssh_user}/subspace/subspace/docker-compose.yml up -d",
    ]
  }
}
