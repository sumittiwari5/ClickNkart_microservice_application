output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.this.address
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.this.port
}

output "rds_endpoint_with_port" {
  description = "RDS endpoint with port"
  value       = "${aws_db_instance.this.address}:${aws_db_instance.this.port}"
}

output "rds_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.this.id
}

output "rds_arn" {
  description = "RDS ARN"
  value       = aws_db_instance.this.arn
}