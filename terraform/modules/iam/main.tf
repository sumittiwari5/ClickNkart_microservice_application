# WHY IAM IS ITS OWN MODULE, SEPARATE FROM EKS:
# IAM roles are referenced by BOTH the EKS module (cluster role, node role)
# AND, later, by IRSA (IAM Roles for Service Accounts) for individual pods
# like the AWS Load Balancer Controller and Cluster Autoscaler that need
# their own narrow AWS permissions. Keeping IAM separate means you can see
# every permission this whole project has, in one place, without hunting
# through the EKS module - important for a security review, which real
# teams actually do.

# ---------------- EKS Cluster Role ----------------
# This is the role the EKS CONTROL PLANE itself assumes (not your pods,
# not your nodes - literally the managed Kubernetes API server AWS runs
# for you). It needs permission to create/manage the underlying AWS
# resources (ENIs, load balancers) that back Kubernetes objects.
resource "aws_iam_role" "eks_cluster" {
  name = "${var.project_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# ---------------- EKS Node Group Role ----------------
# This is the role your EC2 WORKER NODES assume - different from the
# cluster role above. Nodes need permission to register themselves with
# the cluster, pull images from ECR, and manage their own networking.
resource "aws_iam_role" "eks_node_group" {
  name = "${var.project_name}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "node_worker_policy" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy" # lets nodes assign pod IP addresses (the VPC CNI plugin)
}

resource "aws_iam_role_policy_attachment" "node_ecr_readonly" {
  role       = aws_iam_role.eks_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly" # lets nodes pull your Docker images from ECR
}