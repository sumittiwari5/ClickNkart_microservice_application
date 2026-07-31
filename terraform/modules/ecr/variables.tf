variable "project_name" {
  description = "Project name used as the prefix for AWS resources"
  type    = string
  default = "clickncart"
}
variable "services" {
  description = "One ECR repository per deployable image"
  type        = list(string)
  default     = ["user-service", "catalog-service", "order-service", "frontend"]
}