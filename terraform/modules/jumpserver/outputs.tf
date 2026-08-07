output "instance_id" {
  description = "Jump Server instance ID"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Jump Server private IP"
  value       = aws_instance.this.private_ip
}

output "instance_arn" {
  description = "Jump Server ARN"
  value       = aws_instance.this.arn
}