output "role_arn" {
  description = "Set this as the AWS_ROLE_ARN repository variable"
  value       = aws_iam_role.github_actions.arn
}
