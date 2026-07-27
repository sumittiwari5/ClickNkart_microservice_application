variable "aws_region" {
    type = string
    default = "ap-south-1"
}

variable "admin_ip_cidr" {
    description = "Your public IP in CIDR form, e.g. 203.0.113.5/32 - get it from curl ifconfig.me"
    type = sting
}

variable "db_password" {
    description = "Password for the RDS database"
    type = string
    sensitive = true
}