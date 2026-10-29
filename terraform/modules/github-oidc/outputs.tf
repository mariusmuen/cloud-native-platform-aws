output "role_arn" {
  description = "attribute .arn of the role"
  value       = aws_iam_role.github_actions.arn
}

