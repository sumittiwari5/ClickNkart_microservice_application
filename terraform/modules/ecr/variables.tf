variable "project_name" {
  type    = string
  default = "clickncart"
}
variable "services" {
  description = "One ECR repository per deployable image"
  type        = list(string)
  default     = ["user-service", "catalog-service", "order-service", "frontend"]
}