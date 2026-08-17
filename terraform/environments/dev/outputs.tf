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

# ============================================
# Jumpserver
# ============================================
output "jumpserver_instance_id" {
  value = module.jumpserver.instance_id
}

output "jumpserver_private_ip" {
  value = module.jumpserver.private_ip
}

# ============================================
# Security Group IDs 
# ============================================

output "jumpserver_security_group_id" {
  value = module.security_groups.jumpserver_security_group_id
}

output "eks_cluster_security_group_id" {
  value = module.security_groups.eks_cluster_security_group_id
}

output "eks_nodes_security_group_id" {
  value = module.security_groups.eks_nodes_security_group_id
}

output "rds_security_group_id" {
  value = module.security_groups.rds_security_group_id
}