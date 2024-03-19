locals {
  farmer_nodes_ipv4 = flatten([
    [module.farmer_node.*.public_ip]
    ]
  )
  farmer_nodes_ipv6 = flatten([
    [module.farmer_node.*.ipv6_addresses]
    ]
  )
}

resource "null_resource" "setup-farmer-nodes" {
  count = length(local.farmer_nodes_ipv4)

  depends_on = [module.farmer_node]

  # trigger on node ip changes
  triggers = {
    cluster_instance_ipv4s = join(",", local.farmer_nodes_ipv4)
  }

  connection {
    host        = local.farmer_nodes_ipv4[count.index]
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
      "sudo chown -R ${var.ssh_user}:${var.ssh_user} /home/${var.ssh_user}/subspace/ && sudo chmod -R 750 /home/${var.ssh_user}/subspace/",
      "sudo mkdir -p /home/${var.ssh_user}/subspace/farmer_data/ && sudo chmod -R 770 /home/${var.ssh_user}/subspace/farmer_data/",
    ]
  }

  # copy install file
  provisioner "file" {
    source      = "${var.path_to_scripts}/installer.sh"
    destination = "/home/${var.ssh_user}/subspace/installer.sh"
  }

  # copy config files
  provisioner "file" {
    source      = "${var.path_to_configs}/"
    destination = "/home/${var.ssh_user}/subspace/"
  }

  # install docker and docker compose
  provisioner "remote-exec" {
    inline = [
      "sudo bash /home/${var.ssh_user}/subspace/installer.sh",
    ]
  }

}

resource "null_resource" "prune-farmer-nodes" {
  count      = module.farmer-node-config.prune ? length(local.farmer_nodes_ipv4) : 0
  depends_on = [null_resource.setup-farmer-nodes]

  triggers = {
    prune = module.farmer-node-config.prune
  }

  connection {
    host        = local.farmer_nodes_ipv4[count.index]
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
      "sudo bash /home/${var.ssh_user}/subspace/prune_docker_system.sh"
    ]
  }
}

resource "null_resource" "start-farmer-nodes" {
  count = length(local.farmer_nodes_ipv4)

  depends_on = [null_resource.setup-farmer-nodes]

  # trigger on node deployment version change
  triggers = {
    deployment_version = module.farmer-node-config.deployment-version
    reserved_only      = module.farmer-node-config.reserved-only
  }

  connection {
    host        = local.farmer_nodes_ipv4[count.index]
    user        = var.ssh_user
    type        = "ssh"
    agent       = true
    private_key = file("${var.private_key_path}")
    timeout     = "300s"
  }

  # copy farmer identity files (todo: reset this after)
  provisioner "file" {
    source      = "./identity.bin"
    destination = "/home/${var.ssh_user}/subspace/identity.bin"
  }

  # copy node keys file
  provisioner "file" {
    source      = "./farmer_node_keys.txt"
    destination = "/home/${var.ssh_user}/subspace/node_keys.txt"
  }

  # copy boostrap node keys file
  provisioner "file" {
    source      = "./bootstrap_node_keys.txt"
    destination = "/home/${var.ssh_user}/subspace/bootstrap_node_keys.txt"
  }

  # copy DSN bootstrap node keys file
  provisioner "file" {
    source      = "./dsn_bootstrap_node_keys.txt"
    destination = "/home/${var.ssh_user}/subspace/dsn_bootstrap_node_keys.txt"
  }

  # copy compose file creation script
  provisioner "file" {
    source      = "${var.path_to_scripts}/create_farmer_node_compose_file.sh"
    destination = "/home/${var.ssh_user}/subspace/create_compose_file.sh"
  }

  # start docker containers
  provisioner "remote-exec" {
    inline = [
      # inject farmer identity // todo: make configurable as not needed with devnet
      "sudo cp -rf /home/${var.ssh_user}/subspace/identity.bin  /home/${var.ssh_user}/subspace/farmer_data/",
      "sudo chown -R nobody:nogroup /home/${var.ssh_user}/subspace/farmer_data/",
      # stop any running service
      "sudo docker compose -f /home/${var.ssh_user}/subspace/docker-compose.yml down ",

      # set hostname
      "sudo hostnamectl set-hostname ${var.network_name}-farmer-node-${count.index}",

      # create .env file
      "echo NODE_ORG=${module.farmer-node-config.docker-org} > /home/${var.ssh_user}/subspace/.env",
      "echo NODE_TAG=${module.farmer-node-config.docker-tag} >> /home/${var.ssh_user}/subspace/.env",
      "echo NETWORK_NAME=${var.network_name} >> /home/${var.ssh_user}/subspace/.env",
      "echo NODE_ID=${count.index} >> /home/${var.ssh_user}/subspace/.env",
      "echo NODE_KEY=$(sed -nr 's/NODE_${count.index}_KEY=//p' /home/${var.ssh_user}/subspace/node_keys.txt) >> /home/${var.ssh_user}/subspace/.env",
      "echo NR_API_KEY=${var.nr_api_key} >> /home/${var.ssh_user}/subspace/.env",
      "echo REWARD_ADDRESS=${module.farmer-node-config.reward-address} >> /home/${var.ssh_user}/subspace/.env",
      "echo PLOT_SIZE=${module.farmer-node-config.plot-size} >> /home/${var.ssh_user}/subspace/.env",
      "echo PIECE_CACHE_SIZE=${var.piece_cache_size} >> /home/${var.ssh_user}/subspace/.env",
      "echo NODE_DSN_PORT=${module.farmer-node-config.node-dsn-port} >> /home/${var.ssh_user}/subspace/.env",
      "echo POT_EXTERNAL_ENTROPY=${var.pot_external_entropy} >> /home/${var.ssh_user}/subspace/.env",

      # create docker compose file
      "bash /home/${var.ssh_user}/subspace/create_compose_file.sh ${var.bootstrap-node-config.reserved-only} ${length(local.farmer_nodes_ipv4)} ${count.index} ${length(local.bootstrap_nodes_ip_v4)} ${module.farmer-node-config.force-block-production}",

      # start subspace
      "sudo docker compose -f /home/${var.ssh_user}/subspace/docker-compose.yml up -d",
    ]
  }
}
