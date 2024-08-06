module "network" {
  source          = "../../templates/terraform/hetzner"
  path_to_scripts = "../../templates/scripts"
  network_name    = var.network_name

  bootstrap-node-config = {
    deployment-version  = 1
    instance-count      = var.instance_count["bootstrap"]
    repo-org            = "autonomys"
    node-tag            = "bootstrap-node"
    additional-node-ips = var.additional_node_ips["bootstrap"]
    reserved-only       = true
    prune               = false
    genesis-hash        = var.genesis_hash
    dsn-listen-port     = 30533
    node-dsn-port       = 30433
  }

  bootstrap-node-evm-config = {
    deployment-version  = 1
    instance-count      = var.instance_count["bootstrap"]
    repo-org            = "autonomys"
    node-tag            = "bootstrap-node"
    additional-node-ips = var.additional_node_ips["bootstrap"]
    reserved-only       = true
    prune               = false
    genesis-hash        = var.genesis_hash
    dsn-listen-port     = 30533
    node-dsn-port       = 30433
    operator-port       = 30334
  }

  node-config = {
    deployment-version  = 1
    instance-count      = var.instance_count["node"]
    repo-org            = "autonomys"
    node-tag            = "subspace-node"
    additional-node-ips = var.additional_node_ips["node"]
    reserved-only       = true
    prune               = false
    node-dsn-port       = 30433
  }

  domain-node-config = {
    deployment-version  = 1
    instance-count      = var.instance_count["domain"]
    repo-org            = "autonomys"
    node-tag            = "subspace-node"
    additional-node-ips = var.additional_node_ips["domain"]
    domain-prefix       = "domain"
    reserved-only       = true
    prune               = false
    node-dsn-port       = 30433
    enable-domains      = true
    domain-id           = var.domain_id
    domain-labels       = var.domain_labels
  }

  farmer-node-config = {
    deployment-version     = 1
    instance-count         = var.instance_count["farmer"]
    repo-org               = "autonomys"
    node-tag               = "farmer-node"
    additional-node-ips    = var.additional_node_ips["farmer"]
    reserved-only          = true
    prune                  = false
    plot-size              = "10G"
    reward-address         = var.farmer_reward_address
    force-block-production = true
    node-dsn-port          = 30433

  }

  tf_token         = var.tf_token
  private_key_path = var.private_key_path
  branch_name      = var.branch_name
  ssh_user         = var.ssh_user
  genesis_hash     = var.genesis_hash
}

# External data source to run the shell command and extract the value of the operator bootnode connection parameter
data "external" "operator_peer_multiaddr" {
  program = ["bash", "-c", "echo '{\"OPERATOR_MULTI_ADDR\": \"'$(sed -nr 's/^NODE_0_OPERATOR_MULTI_ADDR=(.*)/\\1/p' ./bootstrap_node_evm_keys.txt)'\"}'"]
}
