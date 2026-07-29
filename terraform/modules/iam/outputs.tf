output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "eks_node_group_role_arn" {
  value = aws_iam_role.eks_node_group.arn
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}