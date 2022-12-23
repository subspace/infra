locals {
  full_node_ip_v4 = flatten([
    [var.full-node-config.additional-node-ips],
    [digitalocean_droplet.full-nodes.*.ipv4_address],
    ]
  )
}

resource "null_resource" "full-node-keys" {
  count = length(local.full_node_ip_v4) > 0 ? 1 : 0

  # trigger on new ipv4 change for any instance since we would need to update reserved ips
  triggers = {
    cluster_instance_ipv4s = join(",", local.full_node_ip_v4)
  }

  # generate rpc node keys
  provisioner "local-exec" {
    command     = "${var.path-to-scripts}/generate_node_keys.sh ${length(local.full_node_ip_v4)} ./full_node_keys.txt"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      NODE_PUBLIC_IPS = join(",", local.full_node_ip_v4)
    }
  }
}

resource "null_resource" "setup-full-nodes" {
  count = length(local.full_node_ip_v4)

  depends_on = [null_resource.full-node-keys, null_resource.start-boostrap-nodes]

  # trigger on node ip changes
  triggers = {
    cluster_instance_ipv4s = join(",", local.full_node_ip_v4)
  }

  connection {
    host           = local.full_node_ip_v4[count.index]
    user           = "root"
    type           = "ssh"
    agent          = true
    agent_identity = var.ssh_identity
    timeout        = "10s"
  }

  # create subspace dir
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /subspace"
    ]
  }

  # copy install file
  provisioner "file" {
    source      = "${var.path-to-scripts}/install_docker.sh"
    destination = "/subspace/install_docker.sh"
  }

  # copy netdata agent file
  provisioner "file" {
    source      = "${var.path-to-scripts}/start_netdata_agent.sh"
    destination = "/subspace/start_netdata_agent.sh"
  }

  # install docker and docker compose
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /subspace/install_docker.sh",
      "sudo /subspace/install_docker.sh",
      "sudo chmod +x /subspace/start_netdata_agent.sh",
      "sudo /subspace/start_netdata_agent.sh ${var.netdata_claim_token} ${var.netdata_claim_rooms} full-node-${count.index}",
      "sudo iptables -I OUTPUT -d 192.168.0.0/16,172.16.0.0/12,10.0.0.0/8 -j DROP",
      "sudo iptables -I FORWARD -o $(ip -o -4 route show to default | grep -E -o 'dev [^ ]*' | awk 'NR==1{print $2}') -d 192.168.0.0/16,172.16.0.0/12,10.0.0.0/8 -j DROP",
    ]
  }

}

resource "null_resource" "start-full-nodes" {
  count = length(local.full_node_ip_v4)

  depends_on = [null_resource.setup-full-nodes, null_resource.boostrap-node-keys]

  # trigger on node deployment version change
  triggers = {
    deployment_version = var.full-node-config.deployment-version
    reserved_only      = var.full-node-config.reserved-only
  }

  connection {
    host           = local.full_node_ip_v4[count.index]
    user           = "root"
    type           = "ssh"
    agent          = true
    agent_identity = var.ssh_identity
    timeout        = "10s"
  }

  # copy node keys file
  provisioner "file" {
    source      = "./full_node_keys.txt"
    destination = "/subspace/node_keys.txt"
  }

  # copy boostrap node keys file
  provisioner "file" {
    source      = "./bootstrap_node_keys.txt"
    destination = "/subspace/bootstrap_node_keys.txt"
  }

  # copy compose file
  provisioner "file" {
    source      = "${var.path-to-scripts}/create_full_node_compose_file.sh"
    destination = "/subspace/create_compose_file.sh"
  }

  # start docker containers
  provisioner "remote-exec" {
    inline = [
      "docker compose -f /subspace/docker-compose.yml down",
      "echo NODE_ORG=${var.full-node-config.docker-org} > /subspace/.env",
      "echo NODE_TAG=${var.full-node-config.docker-tag} >> /subspace/.env",
      "echo NETWORK_NAME=${var.network-name} >> /subspace/.env",
      "echo NODE_ID=${count.index} >> /subspace/.env",
      "echo NODE_KEY=$(sed -nr 's/NODE_${count.index}_KEY=//p' /subspace/node_keys.txt) >> /subspace/.env",
      "sudo chmod +x /subspace/create_compose_file.sh",
      "sudo /subspace/create_compose_file.sh ${var.bootstrap-node-config.reserved-only} ${length(local.full_node_ip_v4)} ${count.index} ${length(local.bootstrap_nodes_ip_v4)}",
      "docker compose -f /subspace/docker-compose.yml up -d --remove-orphans",
      "sudo mkdir -p /etc/iptables/",
      "sudo iptables-save > /etc/iptables/rules.v4",
    ]
  }
}
