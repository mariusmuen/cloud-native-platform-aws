output "repository_urls" {
  description = "Map of service name to repository URL, used by CI to push and by Helm to pull images"
  value       = { for name, repo in aws_ecr_repository.this : name => repo.repository_url }
}

output "repository_arns" {
  description = "Map of service name to repository ARN, used to scope IAM permissions for CI"
  value       = { for name, repo in aws_ecr_repository.this : name => repo.arn }
}
