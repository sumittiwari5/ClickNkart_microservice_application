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
# Used by:
# - Jump Server
# - NAT Gateway
# - Internet-facing ALB
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
# ELASTIC IP FOR NAT GATEWAY
# ============================================================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-nat-eip"
  }
}

# ============================================================
# NAT GATEWAY
#
# One NAT Gateway for this DEV environment.
# It lives in the first public subnet.
# ============================================================

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public[0].id

  tags = {
    Name = "${var.project_name}-${var.environment}-nat"
  }

  depends_on = [
    aws_internet_gateway.this
  ]
}

# ============================================================
# PRIVATE ROUTE TABLES
# ============================================================

resource "aws_route_table" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt-${count.index + 1}"
  }
}

# ============================================================
# PRIVATE DEFAULT ROUTE → NAT GATEWAY
# ============================================================

resource "aws_route" "private_nat" {
  count = length(aws_route_table.private)

  route_table_id = aws_route_table.private[count.index].id

  destination_cidr_block = "0.0.0.0/0"

  nat_gateway_id = aws_nat_gateway.this.id
}

# ============================================================
# PRIVATE ROUTE TABLE ASSOCIATIONS
# ============================================================

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id = aws_subnet.private[count.index].id

  route_table_id = aws_route_table.private[count.index].id
}

# ============================================================
# S3 GATEWAY ENDPOINT
#
# Keeps S3 traffic inside AWS instead of going through NAT.
# ============================================================

resource "aws_vpc_endpoint" "s3" {
  vpc_id = aws_vpc.this.id

  service_name = "com.amazonaws.${var.aws_region}.s3"

  vpc_endpoint_type = "Gateway"

  route_table_ids = aws_route_table.private[*].id

  tags = {
    Name        = "${var.project_name}-${var.environment}-s3-endpoint"
    Project     = var.project_name
    Environment = var.environment
  }
}