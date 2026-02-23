provider "aws" {
  region = var.aws_region
}

############################
# Networking (VPC + Subnets)
############################
module "networking" {
  source = "../../modules/networking"

  project_name = var.project_name
  vpc_cidr     = "10.0.0.0/16"

  # Private subnets for RDS (must span ≥2 AZs)
  private_subnet_a_cidr = "10.0.1.0/24"
  private_subnet_b_cidr = "10.0.2.0/24"

  # Public/VPN subnet
  vpn_subnet_cidr = "10.0.10.0/24"

  az_a = "${var.aws_region}a"
  az_b = "${var.aws_region}b"
}

############################
# RDS (Private PostgreSQL)
############################
module "rds" {
  source = "../../modules/rds"

  project_name = var.project_name
  db_name      = "analytics"
  db_user      = "postgres"
  db_password  = "postgres123"

  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
}

############################
# AWS Client VPN
############################
module "vpn" {
  source = "../../modules/vpn"

  project_name  = var.project_name
  vpn_subnet_id = module.networking.vpn_subnet_id
  vpc_cidr      = "10.0.0.0/16"
}
