output "alb_sg_id" {
  description = "The ID of the security group for the ALB"
  value = aws_security_group.alb.id
}
output "eks_nodes_sg_id" {
  description = "The ID of the security group for the EKS nodes"
  value = aws_security_group.eks_nodes.id
}
output "rds_sg_id" {
  description = "The ID of the security group for the RDS database"
  value = aws_security_group.rds.id
}
output "jenkins_sg_id" {
  description = "The ID of the security group for Jenkins"
  value = aws_security_group.jenkins.id
}