module "network" {
  source          = "../base"
  path_to_scripts = "../base/scripts"
  network_name    = var.network_name

  bootstrap-node-config = {
    instance-type      = var.instance_type
    deployment-version = 1
    regions            = var.aws_region
    instance-count     = var.instance_count["bootstrap"]
    repo-org           = "autonomys"
    docker-tag         = var.branch_name
    reserved-only      = false
    prune              = false
    genesis-hash       = var.genesis_hash
    dsn-listen-port    = 30533
    node-dsn-port      = 30433
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  bootstrap-node-evm-config = {
    instance-type      = var.instance_type
    deployment-version = 1
    regions            = var.aws_region
    instance-count     = var.instance_count["evm_bootstrap"]
    repo-org           = "autonomys"
    docker-tag         = var.branch_name
    reserved-only      = false
    prune              = false
    genesis-hash       = var.genesis_hash
    dsn-listen-port    = 30533
    node-dsn-port      = 30433
    operator-port      = 30334
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  bootstrap-node-autoid-config = {
    instance-type      = var.instance_type
    deployment-version = 1
    regions            = var.aws_region
    instance-count     = var.instance_count["autoid_bootstrap"]
    repo-org           = "autonomys"
    docker-tag         = var.branch_name
    reserved-only      = false
    prune              = false
    genesis-hash       = var.genesis_hash
    dsn-listen-port    = 30533
    node-dsn-port      = 30433
    operator-port      = 30334
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  node-config = {
    instance-type      = var.instance_type
    deployment-version = 1
    regions            = var.aws_region
    instance-count     = var.instance_count["node"]
    repo-org           = "autonomys"
    docker-tag         = var.branch_name
    reserved-only      = false
    prune              = false
    node-dsn-port      = 30433
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  domain-node-config = {
    instance-type      = var.instance_type
    deployment-version = 1
    regions            = var.aws_region
    instance-count     = var.instance_count["domain"]
    repo-org           = "autonomys"
    docker-tag         = var.branch_name
    domain-prefix      = ["nova", "auto"]
    reserved-only      = false
    prune              = false
    node-dsn-port      = 30433
    enable-domains     = true
    domain-id          = var.domain_id
    domain-labels      = var.domain_labels
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
  }

  autoid-node-config = {
    instance-type      = var.instance_type
    deployment-version = 1
    regions            = var.aws_region
    instance-count     = var.instance_count["autoid"]
    repo-org           = "autonomys"
    docker-tag         = var.branch_name
    domain-prefix      = ["autoid"]
    reserved-only      = false
    prune              = false
    node-dsn-port      = 30433
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
    instance-count         = var.instance_count["farmer"]
    repo-org               = "autonomys"
    docker-tag             = var.branch_name
    reserved-only          = false
    prune                  = false
    plot-size              = "10G"
    reward-address         = var.farmer_reward_address
    force-block-production = true
    node-dsn-port          = 30433
    disk-volume-size       = var.disk_volume_size
    disk-volume-type       = var.disk_volume_type

  }

  access_key          = var.access_key
  secret_key          = var.secret_key
  vpc_id              = var.vpc_id
  instance_type       = var.instance_type
  vpc_cidr_block      = var.vpc_cidr_block
  public_subnet_cidrs = var.public_subnet_cidrs
  tf_token            = var.tf_token
  private_key_path    = var.private_key_path
  branch_name         = var.branch_name
  genesis_hash        = var.genesis_hash
}

# External data source to run the shell command and extract the value of the operator bootnode connection parameter
data "external" "operator_peer_evm_multiaddr" {
  program = ["bash", "-c", "echo '{\"OPERATOR_MULTI_ADDR\": \"'$(sed -nr 's/^NODE_0_OPERATOR_MULTI_ADDR=(.*)/\\1/p' ./bootstrap_node_evm_keys.txt)'\"}'"]
}

data "external" "operator_peer_autoid_multiaddr" {
  program = ["bash", "-c", "echo '{\"OPERATOR_MULTI_ADDR\": \"'$(sed -nr 's/^NODE_0_OPERATOR_MULTI_ADDR=(.*)/\\1/p' ./bootstrap_node_autoid_keys.txt)'\"}'"]
}
