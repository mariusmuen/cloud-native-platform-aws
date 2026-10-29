output "role_arn" {
  description = "ARN of the IAM role for GitHub Actions (use as role-to-assume)"
  value       = aws_iam_role.github_actions.arn
}

