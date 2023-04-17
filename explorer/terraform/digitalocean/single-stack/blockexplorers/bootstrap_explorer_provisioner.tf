locals {
  explorer_node_ip_v4 = flatten([
    [digitalocean_droplet.explorer-node-blue.*.ipv4_address],
    [digitalocean_droplet.explorer-node-green.*.ipv4_address],
    ]
  )
}


resource "null_resource" "setup-explorer-nodes" {
  count = length(local.explorer_node_ip_v4)

  depends_on = [cloudflare_record.explorer]

  # trigger on node ip changes
  triggers = {
    cluster_instance_ipv4s = join(",", local.explorer_node_ip_v4)
  }

  connection {
    host           = local.explorer_node_ip_v4[count.index]
    user           = "root"
    type           = "ssh"
    agent          = true
    agent_identity = var.ssh_identity
    timeout        = "30s"
  }

  # create explorer dir
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /explorer"
    ]
  }

  # copy install file
  provisioner "file" {
    source      = "${var.path-to-scripts}/install_docker.sh"
    destination = "/explorer-squid/install_docker.sh"
  }

  provisioner "file" {
    source      = "${var.path-to-scripts}/install_nginx_config.sh"
    destination = "/explorer-squid/install_nginx.sh"
  }

  # install docker and docker compose
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /explorer-squid/install_docker.sh",
      "sudo bash /explorer-squid/install_docker.sh",
    ]
  }

  # install nginx proxy configs
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /explorer-squid/install_nginx_conf.sh",
      "sudo bash /explorer-squid/install_nginx_conf.sh",
    ]
  }

}

resource "null_resource" "prune-explorer-nodes" {
  count      = var.explorer-node-config.prune ? length(local.explorer_node_ip_v4) : 0
  depends_on = [null_resource.setup-explorer-nodes]

  triggers = {
    prune = var.explorer-node-config.prune
  }

  connection {
    host           = local.explorer_node_ip_v4[count.index]
    user           = "root"
    type           = "ssh"
    agent          = true
    agent_identity = var.ssh_identity
    timeout        = "30s"
  }

  # prune network
  provisioner "remote-exec" {
    inline = [
      "docker ps -aq | xargs docker stop",
      "docker system prune -a -f && docker volume ls -q | xargs docker volume rm -f",
    ]
  }
}

# Install Nginx proxy as docker container
resource "docker_image" "nginx" {
  name = "nginx:stable-alpine3.17-slim"
}
resource "docker_container" "nginx-server" {
  name = "nginx-server"
  image = "${docker_image.nginx.latest}"
  ports {
    internal = 80
    external = 80
  }
  volumes {
    container_path  = "/etc/nginx/nginx.conf"
    host_path = "/explorer-squid/nginx.conf"
    read_only = true
  }
}


  # copy nginx configs
provisioner "file" {
  source      = "${var.path-to-scripts}/install_nginx_conf.sh"
  destination = "/archive_squid/install_nginx_conf.sh"
}

resource "null_resource" "start-explorer-nodes" {
  count = length(local.explorer_node_ip_v4)

  depends_on = [null_resource.setup-explorer-nodes]

  # trigger on node deployment environment change
  triggers = {
    deployment_color = var.explorer-node-config.deployment-color
  }

  connection {
    host           = local.explorer_node_ip_v4[count.index]
    user           = "root"
    type           = "ssh"
    agent          = true
    agent_identity = var.ssh_identity
    timeout        = "30s"
  }


  # copy compose file creation script
  provisioner "file" {
    source      = "${var.path-to-scripts}/create_explorer_node_compose_file.sh"
    destination = "/explorer-squid/create_compose_file.sh"
  }

  # copy .env file
  provisioner "file" {
    source      = "${var.path-to-scripts}/set_env_vars.sh"
    destination = "/explorer-squid/set_env_vars.sh"
  }

  # start docker containers
  provisioner "remote-exec" {
    inline = [
      # stop any running service
      "systemctl daemon-reload",
      "systemctl stop docker.service",

      # set hostname
      "hostnamectl set-hostname ${var.network-name}-explorer-node-${count.index}",

      # create .env file
      "sudo chmod +x /explorer-squid/set_env_vars.sh",
      "sudo bash /explorer-squid/set_env_vars.sh",

      # create nginx config files
      "sudo chmod +x /explorer-squid/install_nginx_conf.sh",
      "sudo bash /explorer-squid//install_nginx_conf.sh",

      # create docker compose file
      "sudo chmod +x /explorer-squid/create_compose_file.sh",
      "sudo bash /explorer-squid/create_compose_file.sh",

      # start docker daemon
      "systemctl start docker.service",
    ]
  }
}
