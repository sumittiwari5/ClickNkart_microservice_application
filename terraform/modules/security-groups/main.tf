# WHY EACH SECURITY GROUP EXISTS - the guiding rule throughout is
# "least privilege": every SG only allows the exact traffic that specific
# tier actually needs, from the exact source that should be allowed to
# send it. Nothing is ever opened to 0.0.0.0/0 except the load balancer's
# public HTTP/HTTPS ports.

# ---------------- ALB Security Group ----------------
# The ONLY thing in this entire architecture that the public internet can
# reach directly.
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Allows inbound internet traffic on 80/443 only"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-alb-sg" }
}

# ---------------- EKS Node Security Group ----------------
# Worker nodes accept traffic ONLY from the ALB (for actual app traffic)
# and from each other (pod-to-pod / node-to-node cluster networking).
# Nothing from the raw internet reaches a node directly - this is the
# entire point of the public/private subnet split.
resource "aws_security_group" "eks_nodes" {
  name        = "${var.project_name}-eks-nodes-sg"
  description = "EKS worker nodes - accepts traffic from ALB and other nodes only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Traffic from the ALB"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "Node-to-node cluster traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # nodes need outbound to pull images, hit AWS APIs, etc (routed via the NAT Gateway)
  }

  tags = { Name = "${var.project_name}-eks-nodes-sg" }
}

# ---------------- RDS Security Group ----------------
# This is the most locked-down SG in the whole project on purpose: MySQL
# port 3306 is reachable from EXACTLY ONE place - the EKS node security
# group. Not the internet, not the ALB, not even the Jenkins box. If
# Jenkins ever needs direct DB access (e.g. for a migration job), grant it
# explicitly and narrowly rather than opening this up generally.
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "MySQL RDS - only reachable from EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EKS nodes only"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-rds-sg" }
}

# ---------------- Jenkins Security Group ----------------
# SSH only from your own IP (fill this in - never 0.0.0.0/0 for SSH), plus
# the Jenkins web UI port. Jenkins reaches OUT to everything else it needs
# (AWS API, Docker Hub, ECR, the EKS API server) via normal outbound rules
# - it doesn't need special inbound access to do its job.
variable "admin_ip_cidr" {
  description = "YOUR IP address in CIDR form (e.g. 203.0.113.5/32) - never leave this as 0.0.0.0/0"
  type        = string
}

resource "aws_security_group" "jenkins" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Jenkins server - SSH and web UI restricted to admin IP"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from admin only"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip_cidr]
  }

  ingress {
    description = "Jenkins web UI from admin only"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-jenkins-sg" }
}