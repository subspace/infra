module "gemini-3g" {
  source          = "../../templates/terraform/network-primitives-archive/gemini-3g"
  path_to_scripts = "../../templates/terraform/network-primitives-archive/gemini-3g/scripts"
  path_to_configs = "../../templates/terraform/network-primitives-archive/gemini-3g/configs"
  network_name    = "gemini-3g"
  bootstrap-node-config = {
    instance-type      = var.instance_type["bootstrap"]
    deployment-version = 0
    regions            = var.aws_region
    instance-count     = var.instance_count["bootstrap"]
    docker-org         = "autonomys"
    docker-tag         = "gemini-3g-2024-jan-29"
    reserved-only      = true
    prune              = false
    genesis-hash       = "418040fc282f5e5ddd432c46d05297636f6f75ce68d66499ff4cbda69ccd180b"
    dsn-listen-port    = 30533
    node-dsn-port      = 30433
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  bootstrap-node-evm-config = {
    instance-type      = var.instance_type["evm_bootstrap"]
    deployment-version = 0
    regions            = var.aws_region
    instance-count     = var.instance_count["evm_bootstrap"]
    docker-org         = "autonomys"
    docker-tag         = "gemini-3g-2024-jan-29"
    reserved-only      = false
    prune              = false
    genesis-hash       = "418040fc282f5e5ddd432c46d05297636f6f75ce68d66499ff4cbda69ccd180b"
    dsn-listen-port    = 30533
    node-dsn-port      = 30433
    operator-port      = 40333
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  full-node-config = {
    instance-type      = var.instance_type["full"]
    deployment-version = 0
    regions            = var.aws_region
    instance-count     = var.instance_count["full"]
    docker-org         = "autonomys"
    docker-tag         = "gemini-3g-2024-jan-29"
    reserved-only      = true
    prune              = false
    node-dsn-port      = 30433
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  rpc-node-config = {
    instance-type      = var.instance_type["rpc"]
    deployment-version = 0
    regions            = var.aws_region
    instance-count     = var.instance_count["rpc"]
    docker-org         = "autonomys"
    docker-tag         = "gemini-3g-2024-jan-29"
    domain-prefix      = "rpc"
    reserved-only      = true
    prune              = false
    node-dsn-port      = 30433
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  domain-node-config = {
    instance-type      = var.instance_type["domain"]
    deployment-version = 0
    regions            = var.aws_region
    instance-count     = var.instance_count["domain"]
    docker-org         = "autonomys"
    docker-tag         = "gemini-3g-2024-jan-29"
    domain-prefix      = "nova"
    reserved-only      = true
    prune              = false
    node-dsn-port      = 30433
    enable-domains     = true
    domain-id          = var.domain_id
    domain-labels      = var.domain_labels
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  farmer-node-config = {
    instance-type          = var.instance_type["farmer"]
    deployment-version     = 0
    regions                = var.aws_region
    instance-count         = var.instance_count["farmer"]
    docker-org             = "autonomys"
    docker-tag             = "gemini-3g-2024-jan-29"
    reserved-only          = true
    prune                  = false
    plot-size              = "2G"
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
