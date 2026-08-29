variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "instance_type" {
  description = "Jump Server EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "public_subnet_id" {
  description = "Public subnet for the Jump Server"
  type        = string
}

variable "security_group_id" {
  description = "Security group for the Jump Server"
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile for the Jump Server"
  type        = string
}

variable "key_name" {
  description = "Existing ec2 key pair name"
  type = string  
}