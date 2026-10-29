variable "name" {
  type        = string
  description = "Prefix for resource names; the role is called <name>-github-actions"
}

variable "github_repository" {
  type        = string
  description = "GitHub repository (owner/name) whose main branch may assume the role"
}

variable "ecr_repository_arns" {
  type        = list(string)
  description = "ARNs of the ECR repositories the role may push to"
}
