module "squids" {
  source          = "../../../../templates/terraform/explorer/base/"
  path_to_scripts = "../../../../templates/terraform/explorer/base/scripts"
  path_to_configs = "../../../../templates/terraform/explorer/base/config"
  network_name    = var.network_name

  blue-squid-node-config = {
    deployment-color    = "blue"
    network-name        = "${var.network_name}"
    domain-prefix       = "squid.blue"
    docker-tag          = "latest"
    instance-type       = var.instance_type
    deployment-version  = 0
    regions             = var.aws_region
    instance-count-blue = var.instance_count_blue
    disk-volume-size    = var.disk_volume_size
    disk-volume-type    = var.disk_volume_type
    prune               = false
    environment         = "production"
  }

  green-squid-node-config = {
    deployment-color     = "green"
    network-name         = "${var.network_name}"
    domain-prefix        = "squid.green"
    docker-tag           = "latest"
    instance-type        = var.instance_type
    deployment-version   = 0
    regions              = var.aws_region
    instance-count-green = var.instance_count_green
    disk-volume-size     = var.disk_volume_size
    disk-volume-type     = var.disk_volume_type
    prune                = false
    environment          = "staging"
  }

  nova-blue-squid-node-config = {
    deployment-color    = "blue"
    network-name        = "${var.network_name}"
    domain-prefix       = "nova.blue"
    docker-tag          = "evm-domain"
    instance-type       = var.instance_type
    deployment-version  = 0
    regions             = var.aws_region
    instance-count-blue = var.instance_count_blue
    disk-volume-size    = var.disk_volume_size
    disk-volume-type    = var.disk_volume_type
    prune               = false
    environment         = "production"
  }

  nova-green-squid-node-config = {
    deployment-color     = "green"
    network-name         = "${var.network_name}"
    domain-prefix        = "nova.green"
    docker-tag           = "evm-domain"
    instance-type        = var.instance_type
    deployment-version   = 0
    regions              = var.aws_region
    instance-count-green = 0 #var.instance_count_green
    disk-volume-size     = var.disk_volume_size
    disk-volume-type     = var.disk_volume_type
    prune                = false
    environment          = "staging"
  }

  archive-node-config = {
    network-name       = "${var.network_name}"
    domain-prefix      = "archive"
    node-org           = "autonomys"
    node-tag           = var.node_tag
    docker-tag         = "latest"
    instance-type      = var.instance_type
    deployment-version = 0
    regions            = var.aws_region
    instance-count     = 1
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
    prune              = false
  }

  nova-archive-node-config = {
    network-name       = "${var.network_name}"
    domain-prefix      = "nova.archive"
    node-org           = "autonomys"
    node-tag           = var.node_tag
    docker-tag         = "latest"
    instance-type      = var.instance_type
    deployment-version = 0
    regions            = var.aws_region
    instance-count     = 1
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
    prune              = false
  }

  nova-blockscout-node-config = {
    network-name       = "${var.network_name}"
    domain-prefix      = "nova"
    docker-tag         = "blockscout-backend"
    instance-type      = var.instance_type
    deployment-version = 0
    regions            = var.aws_region
    instance-count     = 1
    disk-volume-size   = var.disk_volume_size
    disk-volume-type   = var.disk_volume_type
    prune              = false
  }

  cloudflare_api_token        = var.cloudflare_api_token
  cloudflare_email            = var.cloudflare_email
  aws_key_name                = var.aws_key_name
  nr_api_key                  = var.nr_api_key
  netdata_token               = var.netdata_token
  access_key                  = var.access_key
  secret_key                  = var.secret_key
  vpc_id                      = var.vpc_id
  vpc_cidr_block              = var.vpc_cidr_block
  public_subnet_cidrs         = var.public_subnet_cidrs
  postgres_password           = var.postgres_password
  prometheus_secret           = var.prometheus_secret
  hasura_graphql_admin_secret = var.hasura_graphql_admin_secret
}
