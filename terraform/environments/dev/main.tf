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

module "irsa" {
  source = "../../modules/irsa"
  eks_oidc_issuer_url = module.eks.oidc_issuer_url
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

# Always resolves to the current Ubuntu 24.04 AMI for your region -
# hardcoding an AMI ID goes stale the moment Canonical publishes a new
# patched image; this data source looks it up fresh on every plan/apply.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical's official AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
resource "aws_instance" "jenkins" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.medium"
  key_name                    = var.jenkins_key_name
  subnet_id                   = module.vpc.public_subnet_ids[0]   # PUBLIC - not private, corrected from last message
  vpc_security_group_ids      = [module.security_groups.jenkins_sg_id]
  associate_public_ip_address = true

  root_block_device {
    volume_size = 40 # GB - Docker images, Jenkins workspace, plugins all live here
    volume_type = "gp3" #  better price/performance than the default gp2
  }

  tags = {
    Name = "clickncart-jenkins"
  }
}
