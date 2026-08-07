output "jumpserver_role_arn" {
  description = "IAM role ARN for the Jump Server"
  value       = aws_iam_role.jumpserver.arn
}

output "jumpserver_role_name" {
  description = "IAM role name for the Jump Server"
  value       = aws_iam_role.jumpserver.name
}

output "jumpserver_instance_profile_name" {
  description = "Instance profile name for the Jump Server"
  value       = aws_iam_instance_profile.jumpserver.name
}