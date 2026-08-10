output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "cluster_name" {
  value = local.cluster_name
}

# ============================================================
# RDS
# ============================================================

output "rds_endpoint" {
  description = "RDS MySQL endpoint"
  value       = module.rds.rds_endpoint
}

output "rds_port" {
  description = "RDS MySQL port"
  value       = module.rds.rds_port
}

output "rds_endpoint_with_port" {
  description = "RDS endpoint with port"
  value       = module.rds.rds_endpoint_with_port
}