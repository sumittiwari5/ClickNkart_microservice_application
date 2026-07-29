variable "project_name" {
  description = "Used as a prefix on every resource name, so you can tell ClickNCart's resources apart from anything else in the account"
  type        = string
  default     = "clickncart"
}

variable "vpc_cidr" {
  description = "The overall IP address range for the whole VPC. /16 gives 65,536 addresses - far more than you need, but leaves room to add more subnets later without redesigning"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Spread subnets across 2 AZs minimum - this is what makes the VPC itself fault-tolerant. If one AZ (physically, one AWS datacenter) has an outage, your app keeps running in the other."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "Public subnets - only the Load Balancer lives here, nothing else"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Private subnets - EKS worker nodes AND RDS live here, with no direct route from the internet"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}