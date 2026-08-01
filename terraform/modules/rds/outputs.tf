output "db_endpoint" {
  description = "The endpoint of the RDS database"
  value = aws_db_instance.main.address
}
output "db_port" {
  description = "The port of the RDS database"
  value = aws_db_instance.main.port
}