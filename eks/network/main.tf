locals {
  name   = var.environment_name
  region = var.aws_region

  vpc_cidr       = var.vpc_cidr
  num_of_subnets = min(length(data.aws_availability_zones.available.names), 3)
  azs            = slice(data.aws_availability_zones.available.names, 0, local.num_of_subnets)

  argocd_secret_manager_name = var.argocd_secret_manager_name_suffix

  hosted_zone_name = var.hosted_zone_name

  tags = {
    project      = local.name
    GithubRepo   = "github.com/autonomys/infra"
    GithubOrg    = "autonomys"
    GithubBranch = "main"
    environment  = var.environment_name
  }
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 6, k)]
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 6, k + 10)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  tags = local.tags
}

# Create Sub HostedZone for our deployment
resource "aws_route53_zone" "sub" {
  name = local.hosted_zone_name
}

# Validate records for the new HostedZone (disable since ACM module will create the NS records)
# resource "aws_route53_record" "ns" {
#   zone_id = aws_route53_zone.sub.zone_id
#   name    = local.hosted_zone_name
#   type    = "NS"
#   ttl     = 300
#   records = aws_route53_zone.sub.name_servers
# }

resource "aws_route53_record" "caa" {
  zone_id = aws_route53_zone.sub.zone_id
  name    = local.hosted_zone_name
  type    = "CAA"
  ttl     = 300
  records = ["0 issue \"amazon.com\"", "0 issuewild \"amazon.com\""]
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = local.hosted_zone_name
  zone_id     = aws_route53_zone.sub.zone_id

  subject_alternative_names = [
    "*.${local.hosted_zone_name}",
  ]

  wait_for_validation    = false
  create_route53_records = true

  tags = {
    Name = "${local.hosted_zone_name}"
  }
}

#---------------------------------------------------------------
# ArgoCD Admin Password credentials with Secrets Manager
# Login to AWS Secrets manager with the same role as Terraform to extract the ArgoCD admin password with the secret name as "argocd"
#---------------------------------------------------------------
resource "random_password" "argocd" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "argocd" {
  name                    = "${local.argocd_secret_manager_name}.${local.name}"
  recovery_window_in_days = 0 # Set to zero for this example to force delete during Terraform destroy
}

resource "aws_secretsmanager_secret_version" "argocd" {
  secret_id     = aws_secretsmanager_secret.argocd.id
  secret_string = random_password.argocd.result
}


#todo get the NS records and create them in cloudflare
