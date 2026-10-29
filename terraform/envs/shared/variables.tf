variable "project" {
  type        = string
  default     = "cnp"
  description = "Short project name, used as prefix for resource names"
}

variable "environment" {
  type        = string
  description = "Name of this stack (shared resources used by all environments)"
}

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region"
}

variable "ecr_repositories" {
  type        = list(string)
  description = "Services built by CI that get their own ECR repository"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository as it appears in the OIDC sub claim (owner@owner_id/repo@repo_id)"
}
