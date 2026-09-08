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
