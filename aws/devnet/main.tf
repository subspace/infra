module "devnet" {
  source          = "../network-primitives"
  path_to_scripts = "../network-primitives/scripts"
  network_name    = "devnet"
  bootstrap-node-config = {
    instance-type      = var.instance_type
    deployment-version = 1
    regions            = var.aws_region
    instance-count     = var.instance_count
    docker-org         = "subspace"
    docker-tag         = "snapshot-2023-jun-27-3"
    reserved-only      = false
    prune              = false
    genesis-hash       = "2e45c5cbc42f10e3faaaaa44618927ee1403a08c9625d70891ae3f2fecc35e0b"
    dsn-listen-port    = 50000
    node-dsn-port      = 30433
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  full-node-config = {
    instance-type      = var.instance_type
    deployment-version = 0
    regions            = var.aws_region
    instance-count     = var.instance_count
    docker-org         = "subspace"
    docker-tag         = "snapshot-2023-jun-27-3"
    reserved-only      = false
    prune              = false
    node-dsn-port      = 30433
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  rpc-node-config = {
    instance-type      = var.instance_type
    deployment-version = 1
    regions            = var.aws_region
    instance-count     = var.instance_count
    docker-org         = "subspace"
    docker-tag         = "snapshot-2023-jun-27-3"
    domain-prefix      = "rpc"
    reserved-only      = false
    prune              = false
    node-dsn-port      = 30433
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  domain-node-config = {
    instance-type      = var.instance_type
    deployment-version = 0
    regions            = var.aws_region
    instance-count     = var.instance_count
    docker-org         = "subspace"
    docker-tag         = "snapshot-2023-jun-27-3"
    domain-prefix      = "domain"
    reserved-only      = false
    prune              = false
    node-dsn-port      = 30434
    enable-domains     = true
    domain-id          = var.domain_id
    domain-labels      = var.domain_labels
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  farmer-node-config = {
    instance-type          = var.instance_type
    deployment-version     = 1
    regions                = var.aws_region
    instance-count         = var.instance_count
    docker-org             = "subspace"
    docker-tag             = "snapshot-2023-jun-27-3"
    reserved-only          = false
    prune                  = false
    plot-size              = "10G"
    reward-address         = var.farmer_reward_address
    force-block-production = false
    node-dsn-port          = 30433
    disk-volume-size       = var.disk_volume_size
    disk-volume-type       = var.disk_volume_type

  }

  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_email     = var.cloudflare_email
  datadog_api_key      = var.datadog_api_key
  access_key           = var.access_key
  secret_key           = var.secret_key

}