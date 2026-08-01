variable "aws_region" {
    type = string
    default = "ap-south-1"
}

variable "admin_ip_cidr" {
    description = "Your public IP in CIDR form, e.g. 203.0.113.5/32 - get it from curl ifconfig.me"
    type = string
}

variable "db_password" {
    description = "Password for the RDS database"
    type = string
    sensitive = true
}

variable "jenkins_key_name" {
  description = "Name of the EC2 Key Pair already registered in AWS (see: aws ec2 import-key-pair)"
  type        = string
  default = "jen_dock"
}
