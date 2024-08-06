locals {
  bootstrap_nodes_evm_ip_v4 = flatten([
    [var.bootstrap-node-evm-config.additional-node-ips]
    ]
  )
}

resource "null_resource" "setup-bootstrap-nodes-evm" {
  count = length(local.bootstrap_nodes_evm_ip_v4)

  # trigger on node ip changes
  triggers = {
    cluster_instance_ipv4s = join(",", local.bootstrap_nodes_evm_ip_v4)
  }

  connection {
    host        = local.bootstrap_nodes_evm_ip_v4[count.index]
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

resource "null_resource" "prune-bootstrap-nodes-evm" {
  count      = var.bootstrap-node-evm-config.prune ? length(local.bootstrap_nodes_evm_ip_v4) : 0
  depends_on = [null_resource.setup-bootstrap-nodes-evm]

  triggers = {
    prune = var.bootstrap-node-evm-config.prune
  }

  connection {
    host        = local.bootstrap_nodes_evm_ip_v4[count.index]
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
      "sudo bash /root/subspace/prune_docker_system.sh"
    ]
  }
}

resource "null_resource" "start-bootstrap-nodes-evm" {
  count = length(local.bootstrap_nodes_evm_ip_v4)

  depends_on = [null_resource.setup-bootstrap-nodes-evm]

  # trigger on node deployment version change
  triggers = {
    deployment_version = var.bootstrap-node-evm-config.deployment-version
    reserved_only      = var.bootstrap-node-evm-config.reserved-only
  }

  connection {
    host        = local.bootstrap_nodes_evm_ip_v4[count.index]
    user        = var.ssh_user
    type        = "ssh"
    agent       = true
    private_key = file("${var.private_key_path}")
    timeout     = "300s"
  }

  # copy bootstrap node keys file
  provisioner "file" {
    source      = "./bootstrap_node_evm_keys.txt"
    destination = "/root/subspace/node_keys.txt"
  }

  # copy boostrap node keys file
  provisioner "file" {
    source      = "./bootstrap_node_keys.txt"
    destination = "/root/subspace/bootstrap_node_keys.txt"
  }

  # copy DSN bootstrap node keys file
  provisioner "file" {
    source      = "./dsn_bootstrap_node_keys.txt"
    destination = "/root/subspace/dsn_bootstrap_node_keys.txt"
  }

  # copy relayer ids
  provisioner "file" {
    source      = "./relayer_ids.txt"
    destination = "/root/subspace/relayer_ids.txt"
  }

  # copy compose file creation script
  provisioner "file" {
    source      = "${var.path_to_scripts}/create_bootstrap_node_evm_compose_file.sh"
    destination = "/root/subspace/create_compose_file.sh"
  }

  # start docker containers
  provisioner "remote-exec" {
    inline = [
      # stop any running service
      "sudo docker compose -f /root/subspace/subspace/docker-compose.yml down ",

      # set hostname
      "sudo hostnamectl set-hostname ${var.network_name}-bootstrap-node-evm-${count.index}",

      # create .env file
      "echo NODE_ORG=${var.bootstrap-node-evm-config.repo-org} > /root/subspace/.env",
      "echo NODE_TAG=${var.bootstrap-node-evm-config.node-tag} >> /root/subspace/.env",
      "echo NETWORK_NAME=${var.network_name} >> /root/subspace/.env",
      "echo NODE_ID=${count.index} >> /root/subspace/.env",
      "echo NODE_KEY=$(sed -nr 's/NODE_${count.index}_KEY=//p' /root/subspace/node_keys.txt) >> /root/subspace/.env",
      "echo DOMAIN_LABEL=${var.domain-node-config.domain-labels[0]} >> /root/subspace/.env",
      "echo DOMAIN_ID=${var.domain-node-config.domain-id[0]} >> /root/subspace/.env",
      "echo RELAYER_SYSTEM_ID=$(sed -nr 's/NODE_${count.index}_RELAYER_SYSTEM_ID=//p' /root/subspace/relayer_ids.txt) >> /root/subspace/.env",
      "echo RELAYER_DOMAIN_ID=$(sed -nr 's/NODE_${count.index}_RELAYER_DOMAIN_ID=//p' /root/subspace/relayer_ids.txt) >> /root/subspace/.env",
      "echo PIECE_CACHE_SIZE=${var.piece_cache_size} >> /root/subspace/.env",
      "echo DSN_NODE_ID=${count.index} >> /root/subspace/.env",
      "echo DSN_NODE_KEY=$(sed -nr 's/NODE_${count.index}_DSN_KEY=//p' /root/subspace/node_keys.txt) >> /root/subspace/.env",
      "echo DSN_LISTEN_PORT=${var.bootstrap-node-evm-config.dsn-listen-port} >> /root/subspace/.env",
      "echo NODE_DSN_PORT=${var.bootstrap-node-evm-config.node-dsn-port} >> /root/subspace/.env",
      "echo OPERATOR_PORT=${var.bootstrap-node-evm-config.operator-port} >> /root/subspace/.env",
      "echo GENESIS_HASH=${var.bootstrap-node-evm-config.genesis-hash} >> /root/subspace/.env",
      "echo BRANCH_NAME=${var.branch_name} >> /root/subspace/.env",

      # create docker compose file
      "bash /root/subspace/create_compose_file.sh ${var.bootstrap-node-evm-config.reserved-only} ${length(local.bootstrap_nodes_evm_ip_v4)} ${count.index} ${length(local.bootstrap_nodes_ip_v4)} ${var.domain-node-config.enable-domains}",

      # start subspace node
      var.branch_name != "main" ? join(" && ", [
        "cp -f /root/subspace/.env /root/subspace/subspace/.env",
        "sudo docker compose -f /root/subspace/subspace/docker-compose.yml up -d"
      ]) : "sudo docker compose -f /root/subspace/docker-compose.yml up -d"
    ]
  }
}
