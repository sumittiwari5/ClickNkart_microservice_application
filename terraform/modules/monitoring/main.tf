# This module is deliberately narrow: it's CloudWatch LOG GROUPS for AWS-
# level infrastructure logs (EKS control plane, VPC Flow Logs) - NOT your
# application metrics/dashboards. Your app-level monitoring (JVM metrics,
# HTTP latency, custom dashboards) is Prometheus + Grafana, installed
# INSIDE the cluster via Helm in the monitoring/ phase - a completely
# separate, more appropriate tool for that job. Mixing the two up is a
# common early mistake: CloudWatch is for AWS's view of your
# infrastructure, Prometheus is for your application's view of itself.

resource "aws_cloudwatch_log_group" "eks_cluster" {
  name              = "/aws/eks/${var.eks_cluster_name}/cluster"
  retention_in_days = 14
}

resource "aws_flow_log" "vpc" {
  count                = var.enable_vpc_flow_logs ? 1 : 0
  vpc_id               = var.vpc_id
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  iam_role_arn         = aws_iam_role.flow_logs[0].arn
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_vpc_flow_logs ? 1 : 0
  name              = "/aws/vpc/${var.project_name}/flow-logs"
  retention_in_days = 14
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = "${var.project_name}-vpc-flow-logs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = "${var.project_name}-vpc-flow-logs-policy"
  role  = aws_iam_role.flow_logs[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "*"
    }]
  })
}

variable "vpc_id" {
  type    = string
  default = ""
}
variable "enable_vpc_flow_logs" {
  description = "Off by default to keep this optional/cheap while learning - flip to true when you want network-level audit visibility"
  type        = bool
  default     = false
}