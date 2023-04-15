module "gemini-3c" {
  source          = "../../network-primitives"
  path-to-scripts = "../../network-primitives/scripts"
  network-name    = "gemini-3c"
  bootstrap-node-config = {
    droplet_size        = var.droplet-size
    deployment-version  = 12
    regions             = []
    nodes-per-region    = 0
    additional-node-ips = var.hetzner_bootstrap_node_ips
    docker-org          = "subspace"
    docker-tag          = "gemini-3c-2023-mar-23"
    reserved-only       = false
    prune               = false
    genesis-hash        = ""
    node-dsn-port       = "30433"
  }
  full-node-config = {
    droplet_size        = var.droplet-size
    deployment-version  = 11
    regions             = []
    nodes-per-region    = 0
    additional-node-ips = var.hetzner_full_node_ips
    docker-org          = "subspace"
    docker-tag          = "gemini-3c-2023-mar-23"
    reserved-only       = false
    prune               = false
    node-dsn-port       = "30433"
  }
  rpc-node-config = {
    droplet_size        = var.droplet-size
    deployment-version  = 11
    regions             = []
    nodes-per-region    = 0
    additional-node-ips = var.hetzner_rpc_node_ips
    docker-org          = "subspace"
    docker-tag          = "gemini-3c-2023-mar-23"
    domain-prefix       = "eu"
    reserved-only       = false
    prune               = false
    node-dsn-port       = "30433"
  }
  farmer-node-config = {
    droplet_size           = var.droplet-size
    deployment-version     = 11
    regions                = ["ams3"]
    nodes-per-region       = 1
    additional-node-ips    = []
    docker-org             = "subspace"
    docker-tag             = "gemini-3c-2023-mar-23"
    reserved-only          = false
    plot-size              = "10G"
    reward-address         = var.farmer-reward-address
    force-block-production = false
    prune                  = false
    node-dsn-port          = "30433"
  }
  piece_cache_size     = "50G"
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_email     = var.cloudflare_email
  do_token             = var.do_token
  ssh_identity         = var.ssh_identity
  datadog_api_key      = var.datadog_api_key
}
