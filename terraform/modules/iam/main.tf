# ============================================================
# JUMP SERVER IAM ROLE
# ============================================================

resource "aws_iam_role" "jumpserver" {
  name = "${var.project_name}-${var.environment}-jumpserver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-jumpserver-role"
    Project     = var.project_name
    Environment = var.environment
  }
}


# ============================================================
# INSTANCE PROFILE
# EC2 requires an instance profile to use the IAM role
# ============================================================

resource "aws_iam_instance_profile" "jumpserver" {
  name = "${var.project_name}-${var.environment}-jumpserver-profile"

  role = aws_iam_role.jumpserver.name

  tags = {
    Name        = "${var.project_name}-${var.environment}-jumpserver-profile"
    Project     = var.project_name
    Environment = var.environment
  }
}

# ============================================================
# JUMP SERVER - EKS Access Policy
# Allows the Jumpserver to query and manage the EKS cluster
# ============================================================

resource "aws_iam_role_policy" "jumpserver_eks" {
  name = "${var.project_name}-${var.environment}-jumpserver-eks"
  role = aws_iam_role.jumpserver.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"

        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup",
          "eks:ListUpdates",
          "eks:DescribeUpdate"
        ]
        
        Resource = "*"
      }
    ]
  })
  
}

# ============================
# aws load balancer controller 
# ===========================

resource "aws_iam_role" "aws_load_balancer_controller" {
  name = "${var.project_name}-${var.environment}-aws-load-balancer-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Federated = var.eks_oidc_provider_arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "${replace(var.eks_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"

            "${replace(var.eks_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.aws_load_balancer_controller.arn
}
