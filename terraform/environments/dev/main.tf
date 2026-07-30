# This file is the "wiring diagram" - it doesn't create any AWS resources
# directly, it just calls each module in dependency order and passes
# outputs from earlier modules as inputs to later ones. Reading this file
# top to bottom IS reading the architecture.

module "vpc" {
  source = "../../modules/vpc"
}

module "security_groups" {
  source        = "../../modules/security-groups"
  vpc_id        = module.vpc.vpc_id
  vpc_cidr      = module.vpc.vpc_cidr
  admin_ip_cidr = var.admin_ip_cidr
}

module "iam" {
  source = "../../modules/iam"
  # NOTE: eks_oidc_issuer_url starts empty (see modules/iam/main.tf default).
  # This is a genuine chicken-and-egg dependency: IAM's OIDC provider needs
  # the EKS cluster's issuer URL, but EKS doesn't exist until IAM's node
  # role exists. The standard resolution (and what you should implement
  # here once you reach this phase): apply EKS first with a placeholder,
  # then a second `terraform apply` to wire the real OIDC URL into IAM.
  # This is a real, common Terraform ordering problem worth understanding,
  # not a mistake in this file.
}

module "eks" {
  source              = "../../modules/eks"
  cluster_role_arn    = module.iam.eks_cluster_role_arn
  node_role_arn       = module.iam.eks_node_group_role_arn
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids
  eks_nodes_sg_id     = module.security_groups.eks_nodes_sg_id
}

module "ecr" {
  source = "../../modules/ecr"
}

module "rds" {
  source              = "../../modules/rds"
  private_subnet_ids  = module.vpc.private_subnet_ids
  rds_sg_id           = module.security_groups.rds_sg_id
  db_password         = var.db_password
}

module "monitoring" {
  source            = "../../modules/monitoring"
  eks_cluster_name  = module.eks.cluster_name
  vpc_id            = module.vpc.vpc_id
}