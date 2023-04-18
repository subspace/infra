resource "digitalocean_droplet" "archive-squid-nodes" {
  count    = length(var.archive-squid-node-config.regions) * var.archive-squid-node-config.nodes-per-region
  image    = "ubuntu-22-10-x64"
  name     = "${var.network-name}-archive-node-${count.index}-${var.archive-squid-node-config.regions[count.index % length(var.archive-squid-node-config.regions)]}"
  region   = var.archive-squid-node-config.regions[count.index % length(var.archive-squid-node-config.regions)]
  size     = var.archive-squid-node-config.droplet_size
  ssh_keys = local.ssh_keys
}


resource "digitalocean_droplet" "explorer-nodes" {
  count    = length(var.explorer-node-config.regions) * var.explorer-node-config.nodes-per-region
  image    = "ubuntu-22-10-x64"
  name     = "${var.network-name}-explorer-node-${count.index}-${var.explorer-node-config.regions[count.index % length(var.explorer-node-config.regions)]}"
  region   = var.explorer-node-config.regions[count.index % length(var.explorer-node-config.regions)]
  size     = var.explorer-node-config.droplet_size
  ssh_keys = local.ssh_keys
}
