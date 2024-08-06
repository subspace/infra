locals {
  bootstrap_nodes_ip_v4 = flatten([
    [var.bootstrap-node-config.additional-node-ips]
    ]
  )
}

resource "null_resource" "setup-bootstrap-nodes" {
  count = length(local.bootstrap_nodes_ip_v4)

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
      "sudo mkdir -p /root/subspace/",
      "sudo chown -R ${var.ssh_user}:${var.ssh_user} /root/subspace/ && sudo chmod -R 750 /root/subspace/"
    ]
  }

  # copy install file
  provisioner "file" {
    source      = "${var.path_to_scripts}/installer.sh"
    destination = "/root/subspace/installer.sh"
  }

  # install docker and docker compose
  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/subspace/installer.sh",
      "sudo bash /root/subspace/installer.sh",
    ]
  }
}

resource "null_resource" "clone_branch" {
  count = var.branch_name != "main" ? 1 : 0

  provisioner "remote-exec" {
    inline = [
      "cd /root/subspace/",
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
    destination = "/root/subspace/prune_docker_system.sh"
  }

  # prune network
  provisioner "remote-exec" {
    inline = [
      "chmod +x /root/subspace/prune_docker_system.sh",
      "sudo bash /root/subspace/prune_docker_system.sh"
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
    destination = "/root/subspace/node_keys.txt"
  }

  # copy DSN bootstrap node keys file
  provisioner "file" {
    source      = "./dsn_bootstrap_node_keys.txt"
    destination = "/root/subspace/dsn_bootstrap_node_keys.txt"
  }

  # copy compose file creation script
  provisioner "file" {
    source      = "${var.path_to_scripts}/create_bootstrap_node_compose_file.sh"
    destination = "/root/subspace/create_compose_file.sh"
  }

  # start docker containers
  provisioner "remote-exec" {
    inline = [
      # stop any running service
      "sudo docker compose -f /root/subspace/subspace/docker-compose.yml down ",

      # set hostname
      "sudo hostnamectl set-hostname ${var.network_name}-bootstrap-node-${count.index}",

      # create .env file
      "echo REPO_ORG=${var.bootstrap-node-config.repo-org} > /root/subspace/.env",
      "echo NODE_TAG=${var.bootstrap-node-config.node-tag} >> /root/subspace/.env",
      "echo NETWORK_NAME=${var.network_name} >> /root/subspace/.env",
      "echo NODE_ID=${count.index} >> /root/subspace/.env",
      "echo NODE_KEY=$(sed -nr 's/NODE_${count.index}_KEY=//p' /root/subspace/node_keys.txt) >> /root/subspace/.env",
      "echo PIECE_CACHE_SIZE=${var.piece_cache_size} >> /root/subspace/.env",
      "echo DSN_NODE_ID=${count.index} >> /root/subspace/.env",
      "echo DSN_NODE_KEY=$(sed -nr 's/NODE_${count.index}_KEY=//p' /root/subspace/dsn_bootstrap_node_keys.txt) >> /root/subspace/.env",
      "echo DSN_LISTEN_PORT=${var.bootstrap-node-config.dsn-listen-port} >> /root/subspace/.env",
      "echo NODE_DSN_PORT=${var.bootstrap-node-config.node-dsn-port} >> /root/subspace/.env",
      "echo GENESIS_HASH=${var.bootstrap-node-config.genesis-hash} >> /root/subspace/.env",
      "echo BRANCH_NAME=${var.branch_name} >> /root/subspace/.env",

      # create docker compose file
      "bash /root/subspace/create_compose_file.sh ${var.bootstrap-node-config.reserved-only} ${length(local.bootstrap_nodes_ip_v4)} ${count.index}",

      # start subspace node
      var.branch_name != "main" ? join(" && ", [
        "cp -f /root/subspace/.env /root/subspace/subspace/.env",
        "sudo docker compose -f /root/subspace/subspace/docker-compose.yml up -d"
      ]) : "sudo docker compose -f /root/subspace/docker-compose.yml up -d"
    ]
  }
}
