# ============================================================
# VPC
# ============================================================

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"

    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}


# ============================================================
# INTERNET GATEWAY
# ============================================================

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}


# ============================================================
# PUBLIC SUBNETS
# Used by ALB and Jump Server
# ============================================================

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-${count.index + 1}"

    "kubernetes.io/role/elb" = "1"

    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}


# ============================================================
# PRIVATE SUBNETS
# Used by EKS worker nodes
# ============================================================

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-${var.environment}-private-${count.index + 1}"

    "kubernetes.io/role/internal-elb" = "1"

    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}


# ============================================================
# PUBLIC ROUTE TABLE
# ============================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}


# ============================================================
# PUBLIC ROUTE TABLE ASSOCIATIONS
# ============================================================

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


# ============================================================
# PRIVATE ROUTE TABLE
#
# IMPORTANT:
# No NAT Gateway.
#
# Private subnets use VPC endpoints to access AWS services.
# ============================================================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt"
  }
}


# ============================================================
# PRIVATE ROUTE TABLE ASSOCIATIONS
# ============================================================

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


# ============================================================
# VPC ENDPOINT SECURITY GROUP
# ============================================================

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.project_name}-${var.environment}-vpc-endpoints-sg"
  description = "Allow HTTPS traffic to VPC endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTPS from VPC"

    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = [
      var.vpc_cidr
    ]
  }

  egress {
    description = "Allow all outbound traffic"

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc-endpoints-sg"
  }
}


# ============================================================
# S3 GATEWAY ENDPOINT
#
# ECR uses S3 for image layers.
# Gateway endpoints have no hourly charge.
# ============================================================

resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.this.id

  service_name = "com.amazonaws.${var.aws_region}"

  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private.id
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-s3-endpoint"
  }
}


# ============================================================
# ECR API ENDPOINT
# ============================================================

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id = aws_vpc.this.id

  service_name = "com.amazonaws.${var.aws_region}.ecr.api"

  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-${var.environment}-ecr-api-endpoint"
  }
}


# ============================================================
# ECR DKR ENDPOINT
# ============================================================

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id = aws_vpc.this.id

  service_name = "com.amazonaws.${var.aws_region}.ecr.dkr"

  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-${var.environment}-ecr-dkr-endpoint"
  }
}


# ============================================================
# EC2 ENDPOINT
# Required by several AWS components.
# ============================================================

resource "aws_vpc_endpoint" "ec2" {
  vpc_id = aws_vpc.this.id

  service_name = "com.amazonaws.${var.aws_region}.ec2"

  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2-endpoint"
  }
}


# ============================================================
# STS ENDPOINT
# Required for IAM roles for service accounts.
# ============================================================

resource "aws_vpc_endpoint" "sts" {
  vpc_id = aws_vpc.this.id

  service_name = "com.amazonaws.${var.aws_region}.sts"

  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-${var.environment}-sts-endpoint"
  }
}


# ============================================================
# SSM ENDPOINT
# Useful for managing instances without SSH/EIP.
# ============================================================

resource "aws_vpc_endpoint" "ssm" {
  vpc_id = aws_vpc.this.id

  service_name = "com.amazonaws.${var.aws_region}.ssm"

  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-${var.environment}-ssm-endpoint"
  }
}


# ============================================================
# SSM MESSAGES ENDPOINT
# ============================================================

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id = aws_vpc.this.id

  service_name = "com.amazonaws.${var.aws_region}.ssmmessages"

  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-${var.environment}-ssmmessages-endpoint"
  }
}


# ============================================================
# EC2 MESSAGES ENDPOINT
# ============================================================

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id = aws_vpc.this.id

  service_name = "com.amazonaws.${var.aws_region}.ec2messages"

  vpc_endpoint_type = "Interface"

  subnet_ids = aws_subnet.private[*].id

  security_group_ids = [
    aws_security_group.vpc_endpoints.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "${var.project_name}-${var.environment}-ec2messages-endpoint"
  }
}