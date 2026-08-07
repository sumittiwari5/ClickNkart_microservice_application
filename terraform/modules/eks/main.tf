module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  endpoint_public_access  = true
  endpoint_private_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  addons = {
    coredns = {
      most_recent = true
    }

    kube-proxy = {
      most_recent = true
    }

    vpc-cni = {
      most_recent = true
    }

    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    main = {
      name = "${var.cluster_name}-nodes"

      instance_types = [var.node_instance_type]

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      subnet_ids = var.private_subnet_ids

      ami_type = "AL2023_x86_64_STANDARD"

      capacity_type = "ON_DEMAND"

      disk_size = 30

      labels = {
        environment = var.environment
        project     = var.project_name
      }

      tags = {
        Name = "${var.cluster_name}-worker"
      }
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}