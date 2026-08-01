output "vpc_id" {
  description = "The unique ID of the main VPC"
  value = module.vpc.vpc_id
}
output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value = module.eks.cluster_name
}
output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value = module.eks.cluster_endpoint
}
output "ecr_repository_urls" {
  description = "The URLs of the ECR repositories"
  value = module.ecr.repository_urls
}
output "rds_endpoint" {
  description = "The endpoint of the RDS database"
  value = module.rds.db_endpoint
}