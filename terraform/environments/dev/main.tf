locals {
  cluster_name = "${var.project_name}-${var.environment}-eks"
}

module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  cluster_name = local.cluster_name

  aws_region = var.aws_region

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security_groups" {
  source = "../../modules/security-groups"

  project_name = var.project_name
  environment  = var.environment

  vpc_id = module.vpc.vpc_id

  admin_ip_cidr = var.admin_ip_cidr
}

module "rds" {
  source = "../../modules/rds"

  project_name = var.project_name
  environment  = var.environment

  private_subnet_ids = module.vpc.private_subnet_ids

  rds_security_group_id = module.security_groups.rds_security_group_id

  engine_version = var.rds_engine_version

  instance_class        = var.rds_instance_class
  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage

  db_name     = var.rds_db_name
  db_username = var.rds_db_username
  db_password = var.rds_db_password

  backup_retention_period = var.rds_backup_retention_period

  skip_final_snapshot = var.rds_skip_final_snapshot
  deletion_protection = var.rds_deletion_protection

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "eks" {
  source = "../../modules/eks"

  project_name = var.project_name
  environment  = var.environment

  cluster_name       = local.cluster_name
  kubernetes_version = var.kubernetes_version

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

  node_instance_type = var.node_instance_type

  node_min_size     = var.node_min_size
  node_max_size     = var.node_max_size
  node_desired_size = var.node_desired_size

  jumpserver_role_arn = module.iam.jumpserver_role_arn
}

resource "aws_security_group_rule" "rds_from_eks_nodes" {
  description              = "MySQL access from EKS nodes"
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"

  security_group_id        = module.security_groups.rds_security_group_id
  source_security_group_id = module.eks.node_security_group_id
}

module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  environment  = var.environment
}

module "jumpserver" {
  source = "../../modules/jumpserver"

  project_name = var.project_name
  environment  = var.environment

  instance_type = var.jumpserver_instance_type

  public_subnet_id = module.vpc.public_subnet_ids[0]

  security_group_id = module.security_groups.jumpserver_security_group_id

  instance_profile_name = module.iam.jumpserver_instance_profile_name
}