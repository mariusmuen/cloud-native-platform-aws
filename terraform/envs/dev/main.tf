provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

locals {
  name_prefix = "${var.project}-${var.environment}"
}

module "vpc" {
  source = "../../modules/vpc"

  name               = local.name_prefix
  cidr               = var.vpc_cidr
  azs                = var.azs
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
  single_nat_gateway = var.single_nat_gateway
}

module "eks" {
  source = "../../modules/eks"

  name               = local.name_prefix
  kubernetes_version = var.kubernetes_version
  subnet_ids         = module.vpc.private_subnet_ids
}

