output "repository_urls" {
  description = "A map of ECR repository names to their URLs"
  value = { for k, v in aws_ecr_repository.services : k => v.repository_url }
}