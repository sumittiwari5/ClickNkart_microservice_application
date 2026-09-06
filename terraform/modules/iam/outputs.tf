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

output "aws_load_balancer_controller_role_arn" {
  description = "IAM role ARN for AWS Load Balancer Controller"
  value       = aws_iam_role.aws_load_balancer_controller.arn
}
