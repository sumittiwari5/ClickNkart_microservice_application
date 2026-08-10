variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "clickncart"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)

  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)

  default = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}

variable "node_instance_type" {
  description = "EKS worker node instance type"
  type        = string
  default     = "t3.large"
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 4
}

variable "jumpserver_instance_type" {
  description = "Jump server instance type"
  type        = string
  default     = "t3.large"
}

variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

variable "admin_ip_cidr" {
  description = "Your public IP in CIDR /32 format"
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type    = string
  default = "1.34"
}

# ============================================================
# RDS
# ============================================================

variable "rds_engine_version" {
  description = "MySQL engine version for RDS"
  type        = string
  default     = "8.0"
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Initial RDS storage in GB"
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Maximum RDS storage in GB"
  type        = number
  default     = 50
}

variable "rds_db_name" {
  description = "Initial database created by RDS"
  type        = string
  default     = "clickncart"
}

variable "rds_db_username" {
  description = "RDS master username"
  type        = string
  sensitive   = true
}

variable "rds_db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "rds_backup_retention_period" {
  description = "RDS automated backup retention period in days"
  type        = number
  default     = 7
}

variable "rds_skip_final_snapshot" {
  description = "Skip final RDS snapshot when destroying the database"
  type        = bool
  default     = true
}

variable "rds_deletion_protection" {
  description = "Enable RDS deletion protection"
  type        = bool
  default     = false
}