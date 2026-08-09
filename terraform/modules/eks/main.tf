module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version
#-------------------
# Networkins :
#-------------------

  endpoint_public_access  = true
  endpoint_private_access = true

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

#-------------
# EKS Access :
#-------------
   authentication_mode = "API_AND_CONFIG_MAP"

  access_entries = {
    jumpserver = {
      principal_arn = var.jumpserver_role_arn

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

#----------------------
# EKS Addons :
#----------------------

  addons = {
    coredns = {
      most_recent = true

      before_compute = true
    }

    kube-proxy = {
      most_recent = true

      before_compute = true
    }

    vpc-cni = {
      most_recent = true

      before_compute = true

      configuration_values = jsonencode({
        env = {
          ENABLE_PREFIX_DELEGATION = "false"
        }
      })
    }

    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  #------------------------
  # Managed Node Group :
  #------------------------

  eks_managed_node_groups = {
    main = {
      name = "${var.cluster_name}-nodes"

      iam_role_name = "clickncart-dev-node-role"

      iam_role_additional_policies = {
        AmazonEKSWorkerNodePolicy = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

        AmazonEC2ContainerRegistryPullOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"

        AmazonEKS_CNI_Policy = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
     }

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