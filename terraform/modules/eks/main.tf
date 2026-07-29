# WHY MANAGED NODE GROUPS (not Fargate, per your requirement):
# Managed Node Groups give you real EC2 instances you can see, SSH into
# (if you choose), size deliberately, and reason about like the EC2
# instances you already know from the ClickNCart EKS/Fargate work. AWS
# still handles the tedious parts (bootstrapping the AMI, joining the
# cluster, replacing unhealthy nodes) - you just choose instance types,
# counts, and let the Cluster Autoscaler manage scaling between them.
#
# WHY THREE SEPARATE NODE GROUPS instead of one:
# This is what makes "Jenkins must never host production apps" and
# "frontend needs small instances, backend needs large ones" actually
# enforceable - not just a hope. Each node group gets its own instance
# type/size AND a Kubernetes taint, so the scheduler physically cannot
# place a pod on the wrong node group unless that pod explicitly
# tolerates the taint (see each Helm chart's values.yaml for the matching
# toleration + nodeSelector).

resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-eks"
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = true # public access needed so you (and Jenkins) can run kubectl/helm from outside the VPC; restrict via public_access_cidrs in a real prod account
  }
}

# ---------------- Jenkins Node Group ----------------
resource "aws_eks_node_group" "jenkins" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-jenkins-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = [var.jenkins_instance_type]

  scaling_config {
    desired_size = 1
    min_size     = 1
    max_size     = 1 # Jenkins is a single stateful instance in this design - it does not horizontally scale like the app tiers do
  }

  labels = {
    role = "jenkins"
  }

  taint {
    key    = "dedicated"
    value  = "jenkins"
    effect = "NO_SCHEDULE" # this is what physically stops any app pod from ever landing here
  }
}

# ---------------- Frontend Node Group ----------------
resource "aws_eks_node_group" "frontend" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-frontend-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = [var.frontend_instance_type]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 4
  }

  labels = {
    role = "frontend"
  }

  taint {
    key    = "dedicated"
    value  = "frontend"
    effect = "NO_SCHEDULE"
  }
}

# ---------------- Backend Node Group ----------------
resource "aws_eks_node_group" "backend" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-backend-ng"
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = [var.backend_instance_type]

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 10 # ceiling for ALL THREE backend services' HPAs combined to scale into - see the HPA math note in docs
  }

  labels = {
    role = "backend"
  }

  taint {
    key    = "dedicated"
    value  = "backend"
    effect = "NO_SCHEDULE"
  }
}