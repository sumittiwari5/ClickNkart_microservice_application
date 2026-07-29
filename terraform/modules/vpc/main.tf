# WHY A CUSTOM VPC AT ALL, INSTEAD OF THE ACCOUNT'S DEFAULT ONE:
# The default VPC AWS gives every account is entirely public subnets, with
# no separation between "things the internet can reach" and "things it
# can't." That's fine for a quick test, but it's the opposite of what a
# real deployment needs: your EKS worker nodes and your RDS database should
# NEVER be directly reachable from the internet - only your Load Balancer
# should be. A custom VPC with real public/private subnet separation is
# what makes that possible.

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true # required for EKS - nodes and the control plane need to resolve each other by DNS name

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# --- Public subnets: one per AZ, only for the Load Balancer ---
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true # instances here get a public IP automatically - fine for a Load Balancer, would be dangerous for a worker node or database

  tags = {
    Name                                          = "${var.project_name}-public-${var.availability_zones[count.index]}"
    "kubernetes.io/role/elb"                      = "1"  # tells the AWS Load Balancer Controller "you're allowed to place a public ALB here"
    "kubernetes.io/cluster/${var.project_name}-eks" = "shared"
  }
}

# --- Private subnets: one per AZ, for EKS nodes + RDS ---
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name                                          = "${var.project_name}-private-${var.availability_zones[count.index]}"
    "kubernetes.io/role/internal-elb"             = "1"  # tells the AWS Load Balancer Controller "internal-only load balancers can go here"
    "kubernetes.io/cluster/${var.project_name}-eks" = "shared"
  }
}

# --- Internet Gateway: the VPC's only direct door to the internet ---
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# --- NAT Gateway: lets PRIVATE subnets reach OUT to the internet, without
# letting the internet reach IN. This is what your worker nodes use to
# pull Docker images, hit the AWS API, etc, while staying unreachable
# directly. It needs to physically sit in a PUBLIC subnet itself. ---
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # one NAT Gateway, in the first public subnet - see the cost note in README about single vs per-AZ NAT

  tags = {
    Name = "${var.project_name}-nat"
  }
  depends_on = [aws_internet_gateway.main]
}

# --- Route tables ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}