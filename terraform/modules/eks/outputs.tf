output "cluster_name" {
  description = "The name of the EKS cluster"
  value = aws_eks_cluster.main.name
}
output "cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value = aws_eks_cluster.main.endpoint
}
output "cluster_certificate_authority" {
  description = "The certificate authority data for the EKS cluster"
  value = aws_eks_cluster.main.certificate_authority[0].data
}
output "oidc_issuer_url" {
  description = "The OIDC issuer URL for the EKS cluster"
  value = aws_eks_cluster.main.identity[0].oidc[0].issuer
}