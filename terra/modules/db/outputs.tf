output "primary_db_endpoint" {
  description = "Primary DB endpoint"
  value       = aws_db_instance.primary.endpoint
}

output "primary_db_port" {
  description = "Primary DB port"
  value       = aws_db_instance.primary.port
}

output "replica_endpoints" {
  description = "List of read replica endpoints"
  value       = [for r in aws_db_instance.replicas : r.endpoint]
}

output "db_security_group_id" {
  description = "DB Security Group ID"
  value       = aws_security_group.db_sg.id
}
