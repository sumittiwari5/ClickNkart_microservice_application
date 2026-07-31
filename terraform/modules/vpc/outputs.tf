output "vpc_id" {
  description = "The unique ID of the main VPC"
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "A list of IDs for all the public subnets in the VPC"
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "A list of IDs for all the private subnets in the VPC"
  value = aws_subnet.private[*].id
}

output "vpc_cidr" {
  description = "The primary IPv4 CIDR block assigned to the VPC"
  value = aws_vpc.main.cidr_block
}