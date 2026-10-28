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
