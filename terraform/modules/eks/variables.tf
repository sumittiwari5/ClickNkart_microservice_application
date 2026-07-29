variable "project_name" {
  type    = string
  default = "clickncart"
}
variable "cluster_role_arn" {
  type = string
}
variable "node_role_arn" {
  type = string
}
variable "private_subnet_ids" {
  type = list(string)
}
variable "public_subnet_ids" {
  type = list(string)
}
variable "eks_nodes_sg_id" {
  type = string
}
variable "kubernetes_version" {
  type    = string
  default = "1.31"
}

# Sizing per node group, as separate variables so the reasoning behind each
# number is visible right here rather than buried in a tfvars file.
variable "jenkins_instance_type" {
  type    = string
  default = "t3.medium" # Jenkins itself + build agents doing Maven/npm builds need real CPU/RAM during builds
}
variable "frontend_instance_type" {
  type    = string
  default = "t3.small" # static nginx-served React build - genuinely light workload
}
variable "backend_instance_type" {
  type    = string
  default = "t3.large" # 3 JVMs is memory-hungry - undersizing this is the #1 cause of pods stuck Pending
}