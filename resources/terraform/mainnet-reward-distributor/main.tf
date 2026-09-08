module "mainnet_reward_distributor" {
  source = "../../../modules/operator-reward-distributor"
  aws = {
    secret              = var.aws_secret_key
    access_key          = var.aws_access_key
    vpc_id              = "mainnet-chain-reward-distributor-vpc"
    vpc_cidr_block      = "172.40.0.0/16"
    region              = "us-west-1"
    availability_zone   = "us-west-1a"
    public_subnet_cidrs = "172.40.1.0/24"
    ssh_key_name        = var.aws_ssh_key_name
  }

  deployer = {
    ssh_user               = "ubuntu"
    ssh_agent_identity     = var.ssh_agent_identity
    path_to_scripts        = "../../../scripts"
    path_to_docker_compose = "../../../modules/operator-reward-distributor/docker-compose.yml"
    path_to_nginx_conf     = "../../../modules/operator-reward-distributor/nginx.conf"
  }

  instance = {
    network_name        = "mainnet"
    docker_tag          = "latest"
    instance_type       = "t3.medium"
    rpc_url             = "wss://auto-evm.mainnet.autonomys.xyz/ws"
    interval_seconds    = 120
    tip_ai3             = 18
    daily_ai3_cap       = 13500
    max_retries         = 5
    mortality_blocks    = 64
    confirmation_blocks = 5
    account_private_key = var.account_private_key
  }
}
