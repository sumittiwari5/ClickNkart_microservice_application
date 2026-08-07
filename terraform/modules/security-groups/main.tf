resource "aws_security_group" "jumpserver" {
  name        = "${var.project_name}-${var.environment}-jumpserver-sg"
  description = "Security group for ClickNCart Jump Server"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from administrator"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.admin_ip_cidr]
  }

  egress {
    description = "Allow all outbound traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-jumpserver-sg"
  }
}


resource "aws_security_group" "eks_cluster" {
  name        = "${var.project_name}-${var.environment}-eks-cluster-sg"
  description = "Security group for EKS control plane"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Kubernetes API from Jump Server"
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [aws_security_group.jumpserver.id]
  }

  egress {
    description = "Allow all outbound traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-cluster-sg"
  }
}


resource "aws_security_group" "eks_nodes" {
  name        = "${var.project_name}-${var.environment}-eks-nodes-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Node to node communication"
    protocol        = "-1"
    from_port       = 0
    to_port         = 0
    self            = true
  }

  ingress {
    description     = "Kubernetes API from nodes"
    protocol        = "tcp"
    from_port       = 443
    to_port         = 443
    security_groups = [aws_security_group.jumpserver.id]
  }

  ingress {
    description     = "Kubelet"
    protocol        = "tcp"
    from_port       = 10250
    to_port         = 10250
    self            = true
  }

  egress {
    description = "Allow all outbound traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-eks-nodes-sg"
  }
}