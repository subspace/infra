locals {
  farmer_node_ipv4 = flatten([
    [var.farmer-node-config.additional-node-ips]
    ]
  )
}

resource "null_resource" "setup-farmer-nodes" {
  count = length(local.farmer_node_ipv4)

  # trigger on node ip changes
  triggers = {
    cluster_instance_ipv4s = join(",", local.farmer_node_ipv4)
  }

  connection {
    host        = local.farmer_node_ipv4[count.index]
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
      "sudo mkdir -p /root/subspace/farmer_data/",
      "sudo chown -R ${var.ssh_user}:${var.ssh_user} /root/subspace/ && sudo chmod -R 750 /root/subspace/",
      "sudo chown -R nobody:nogroup /root/subspace/farmer_data/"
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
      "sudo /root/subspace/installer.sh",
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

resource "null_resource" "prune-farmer-nodes" {
  count      = var.farmer-node-config.prune ? length(local.farmer_node_ipv4) : 0
  depends_on = [null_resource.setup-farmer-nodes]

  triggers = {
    prune = var.farmer-node-config.prune
  }

  connection {
    host        = local.farmer_node_ipv4[count.index]
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

resource "null_resource" "start-farmer-nodes" {
  count = length(local.farmer_node_ipv4)

  depends_on = [null_resource.setup-farmer-nodes]

  # trigger on node deployment version change
  triggers = {
    deployment_version = var.farmer-node-config.deployment-version
    reserved_only      = var.farmer-node-config.reserved-only
  }

  connection {
    host        = local.farmer_node_ipv4[count.index]
    user        = var.ssh_user
    type        = "ssh"
    agent       = true
    private_key = file("${var.private_key_path}")
    timeout     = "300s"
  }

  # copy node keys file
  provisioner "file" {
    source      = "./farmer_node_keys.txt"
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

  # copy compose file creation script
  provisioner "file" {
    source      = "${var.path_to_scripts}/create_farmer_node_compose_file.sh"
    destination = "/root/subspace/create_compose_file.sh"
  }

  # start docker containers
  provisioner "remote-exec" {
    inline = [
      # stop any running service
      "sudo docker compose -f /root/subspace/subspace/docker-compose.yml down ",

      # set hostname
      "sudo hostnamectl set-hostname ${var.network_name}-farmer-node-${count.index}",

      # create .env file
      "echo REPO_ORG=${var.farmer-node-config.repo-org} > /root/subspace/.env",
      "echo NODE_TAG=${var.farmer-node-config.node-tag} >> /root/subspace/.env",
      "echo NETWORK_NAME=${var.network_name} >> /root/subspace/.env",
      "echo NODE_ID=${count.index} >> /root/subspace/.env",
      "echo NODE_KEY=$(sed -nr 's/NODE_${count.index}_KEY=//p' /root/subspace/node_keys.txt) >> /root/subspace/.env",
      "echo REWARD_ADDRESS=${var.farmer-node-config.reward-address} >> /root/subspace/.env",
      "echo PLOT_SIZE=${var.farmer-node-config.plot-size} >> /root/subspace/.env",
      "echo PIECE_CACHE_SIZE=${var.piece_cache_size} >> /root/subspace/.env",
      "echo NODE_DSN_PORT=${var.farmer-node-config.node-dsn-port} >> /root/subspace/.env",
      "echo BRANCH_NAME=${var.branch_name} >> /root/subspace/.env",

      # create docker compose file
      "bash /root/subspace/create_compose_file.sh ${var.bootstrap-node-config.reserved-only} ${length(local.farmer_node_ipv4)} ${count.index} ${length(local.bootstrap_nodes_ip_v4)} ${var.farmer-node-config.force-block-production}",

      # start subspace node
      var.branch_name != "main" ? join(" && ", [
        "cp -f /root/subspace/.env /root/subspace/subspace/.env",
        "sudo docker compose -f /root/subspace/subspace/docker-compose.yml up -d"
      ]) : "sudo docker compose -f /root/subspace/docker-compose.yml up -d"
    ]
  }
}
