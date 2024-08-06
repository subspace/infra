module "gemini-3f" {
  source          = "../../templates/terraform/network-primitives-archive/gemini-3f"
  path_to_scripts = "../../templates/terraform/network-primitives-archive/gemini-3f/scripts"
  path_to_configs = "../../templates/terraform/network-primitives-archive/gemini-3f/configs"
  network_name    = "gemini-3f"
  bootstrap-node-config = {
    instance-type      = var.instance_type["bootstrap"]
    deployment-version = 1
    regions            = var.aws_region
    instance-count     = var.instance_count["bootstrap"]
    docker-org         = "autonomys"
    docker-tag         = "gemini-3f-2023-oct-06"
    reserved-only      = true
    prune              = false
    genesis-hash       = "92e91e657747c41eeabed5129ff51689d2e935b9f6abfbd5dfcb2e1d0d065095"
    dsn-listen-port    = 30533
    node-dsn-port      = 30433
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  bootstrap-node-evm-config = {
    instance-type      = var.instance_type["evm_bootstrap"]
    deployment-version = 1
    regions            = var.aws_region
    instance-count     = var.instance_count["evm_bootstrap"]
    docker-org         = "autonomys"
    docker-tag         = "gemini-3f-2023-oct-06"
    reserved-only      = false
    prune              = false
    genesis-hash       = "92e91e657747c41eeabed5129ff51689d2e935b9f6abfbd5dfcb2e1d0d065095"
    dsn-listen-port    = 30533
    node-dsn-port      = 30433
    operator-port      = 40333
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  full-node-config = {
    instance-type      = var.instance_type["full"]
    deployment-version = 1
    regions            = var.aws_region
    instance-count     = var.instance_count["full"]
    docker-org         = "autonomys"
    docker-tag         = "gemini-3f-2023-oct-06"
    reserved-only      = true
    prune              = false
    node-dsn-port      = 30433
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  rpc-node-config = {
    instance-type      = var.instance_type["rpc"]
    deployment-version = 1
    regions            = var.aws_region
    instance-count     = var.instance_count["rpc"]
    docker-org         = "autonomys"
    docker-tag         = "gemini-3f-2023-oct-06"
    domain-prefix      = "rpc"
    reserved-only      = true
    prune              = false
    node-dsn-port      = 30433
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  domain-node-config = {
    instance-type      = var.instance_type["domain"]
    deployment-version = 1
    regions            = var.aws_region
    instance-count     = var.instance_count["domain"]
    docker-org         = "autonomys"
    docker-tag         = "gemini-3f-2023-oct-06"
    domain-prefix      = "domain"
    reserved-only      = true
    prune              = false
    node-dsn-port      = 30434
    enable-domains     = true
    domain-id          = var.domain_id
    domain-labels      = var.domain_labels
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  farmer-node-config = {
    instance-type          = var.instance_type["farmer"]
    deployment-version     = 1
    regions                = var.aws_region
    instance-count         = var.instance_count["farmer"]
    docker-org             = "autonomys"
    docker-tag             = "gemini-3f-2023-oct-06"
    reserved-only          = true
    prune                  = false
    plot-size              = "10G"
    reward-address         = var.farmer_reward_address
    force-block-production = true
    node-dsn-port          = 30433
    disk-volume-size       = var.disk_volume_size
    disk-volume-type       = var.disk_volume_type

  }

  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_email     = var.cloudflare_email
  nr_api_key           = var.nr_api_key
  access_key           = var.access_key
  secret_key           = var.secret_key
  vpc_id               = var.vpc_id
  instance_type        = var.instance_type
  vpc_cidr_block       = var.vpc_cidr_block
  public_subnet_cidrs  = var.public_subnet_cidrs

}
