# =======================================================
# NETWORK MODULE OUTPUTS - PYFLEET
# =======================================================

# -------------------------
# VPC
# -------------------------
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

# -------------------------
# Internet Gateway
# -------------------------
output "igw_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.igw.id
}

# -------------------------
# Public Subnets
# -------------------------
output "public_bastion_subnets" {
  description = "List of public subnets for Bastion hosts"
  value       = [for subnet in aws_subnet.public_bastion : subnet.id]
}

output "public_alb_subnets" {
  description = "List of public subnets for ALB"
  value       = [for subnet in aws_subnet.public_alb : subnet.id]
}

# -------------------------
# Private Subnets
# -------------------------
output "private_app_subnets" {
  description = "List of private subnets for application servers"
  value       = [for subnet in aws_subnet.private_app : subnet.id]
}

output "private_db_subnets" {
  description = "List of private subnets for database servers"
  value       = [for subnet in aws_subnet.private_db : subnet.id]
}

# -------------------------
# NAT Gateways
# -------------------------
output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs for private subnets"
  value       = [for nat in aws_nat_gateway.nat : nat.id]
}

# -------------------------
# Route Tables
# -------------------------
output "public_route_table_ids" {
  description = "Route table IDs associated with public subnets"
  value       = [aws_route_table.public.id]
}


output "private_route_table_ids" {
  description = "List of private route table IDs"
  value = concat(
    [for rt in aws_route_table.private_app : rt.id],
    [for rt in aws_route_table.private_db : rt.id]
  )
}
