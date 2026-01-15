
output "bastion_instance_ids" {
  description = "IDs of the bastion EC2 instances (multi-AZ)"
  value       = aws_instance.bastion[*].id
}

output "bastion_public_ips" {
  description = "Public IP addresses of bastion instances"
  value       = aws_instance.bastion[*].public_ip
}

output "bastion_public_dns" {
  description = "Public DNS of bastion instances"
  value       = [for i in aws_instance.bastion : i.public_dns]
}

output "bastion_sg_id" {
  description = "Security group ID of bastion host"
  value       = aws_security_group.bastion.id
}
