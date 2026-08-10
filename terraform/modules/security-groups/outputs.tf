output "jumpserver_security_group_id" {
  value = aws_security_group.jumpserver.id
}


output "rds_security_group_id" {
  value = aws_security_group.rds.id
}