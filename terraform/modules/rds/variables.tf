variable "project_name" {
  type    = string
  default = "clickncart"
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "rds_sg_id" {
  type = string
}
variable "db_instance_class" {
  type    = string
  default = "db.t3.micro" # fine for learning-scale traffic; the honest production sizing conversation is a separate exercise once you have real load numbers
}
variable "db_username" {
  type    = string
  default = "admin"
}
variable "db_password" {
  description = "Set via TF_VAR_db_password env var or terraform.tfvars (gitignored) - NEVER commit this"
  type        = string
  sensitive   = true
}