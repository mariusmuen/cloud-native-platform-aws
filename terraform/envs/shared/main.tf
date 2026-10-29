# Long-lived resources shared by all environments (dev, prod).
# Not destroyed after work sessions: container registry, CI identity.

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
  name_prefix = var.project
}

module "ecr" {
  source = "../../modules/ecr"

  name         = local.name_prefix
  repositories = var.ecr_repositories
}


module "github_oidc" {
  source = "../../modules/github-oidc"

  name                = local.name_prefix
  github_repository   = var.github_repository
  ecr_repository_arns = values(module.ecr.repository_arns)
}
