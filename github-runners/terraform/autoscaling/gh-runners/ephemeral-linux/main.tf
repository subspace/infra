locals {
  environment = var.environment != null ? var.environment : "ephemeral"
  aws_region  = "us-west-2"
}

resource "random_id" "random" {
  byte_length = 20
}

module "base" {
  source = "../base"

  prefix     = local.environment
  aws_region = local.aws_region
}

module "runners" {
  source                          = "../../"
  create_service_linked_role_spot = true
  aws_region                      = local.aws_region
  vpc_id                          = module.base.vpc.vpc_id
  subnet_ids                      = module.base.vpc.private_subnets

  prefix = local.environment
  tags = {
    Project = "subspace-scale-runners"
  }

  github_app = {
    key_base64     = var.github_app.key_base64
    id             = var.github_app.id
    webhook_secret = random_id.random.hex
  }

  # Grab the lambda packages from local directory. Must run /.ci/build.sh first
  webhook_lambda_zip                = "../../lambda_output/webhook.zip"
  runner_binaries_syncer_lambda_zip = "../../lambda_output/runner-binaries-syncer.zip"
  runners_lambda_zip                = "../../lambda_output/runners.zip"

  enable_organization_runners = true
  runner_extra_labels         = [""]

  # enable access to the runners via SSM
  enable_ssm_on_runners = true

  # Let the module manage the service linked role
  create_service_linked_role_spot = true

  instance_types = ["m6a.4xlarge", "c6a.4xlarge"]

  # override delay of events in seconds
  delay_webhook_event = 0

  # Ensure you set the number not too low, each build require a new instance
  runners_maximum_count = 20

  # override scaling down
  scale_down_schedule_expression = "cron(* * * * ? *)"

  enable_ephemeral_runners = true

  # # Example of simple pool usages
  pool_runner_owner = "subspace-scale-runners"
  pool_config = [{
    size                = 3
    schedule_expression = "cron(* * * * ? *)"
  }]

  enable_job_queued_check = true

  tracing_config = {
    mode                  = "Active"
    capture_error         = true
    capture_http_requests = true
  }


  # AMI selection and userdata
  #
  # option 1. configure your pre-built AMI + userdata
  # userdata_template = "./templates/user-data.sh"
  ami_owners = ["099720109477"] # Canonical's Amazon account ID

  ami_filter = {
    name  = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"],
    state = ["available"]
  }

  # Custom build AMI, no custom userdata needed.
  # option 2: Build custom AMI see ../../images/ubuntu-jammy
  #           disable lines above (option 1) and enable the ones below
  # ami_filter = {
  #   name  = ["github-runner-ubuntu-jammy-amd64-202404050401*"],
  #   state = ["available"]
  # }
  # data "aws_caller_identity" "current" {}
  # ami_owners      = ["self"]
  # enable_userdata = false

  # or use the default AMI
  enable_userdata = true

  # Enable debug logging for the lambda functions
  # log_level = "debug"

  # Setup a dead letter queue, by default scale up lambda will kepp retrying to process event in case of scaling error.
  # redrive_policy_build_queue = {
  #   enabled             = true
  #   maxReceiveCount     = 50 # 50 retries every 30 seconds => 25 minutes
  #   deadLetterTargetArn = null
  # }
}

module "webhook_github_app" {
  source     = "../../modules/webhook-github-app"
  depends_on = [module.runners]

  github_app = {
    key_base64     = var.github_app.key_base64
    id             = var.github_app.id
    webhook_secret = random_id.random.hex
  }
  webhook_endpoint = module.runners.webhook.endpoint
}
