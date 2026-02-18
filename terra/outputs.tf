# =======================================================
# ROOT MODULE OUTPUTS
# =======================================================

# -------------------------
# VPC & Networking
# -------------------------
output "vpc_id" {
  description = "VPC ID of the deployment"
  value       = module.network.vpc_id
}

output "public_alb_subnets" {
  description = "List of public subnets for ALB"
  value       = module.network.public_alb_subnets
}

output "public_bastion_subnets" {
  description = "List of public subnets for Bastion hosts"
  value       = module.network.public_bastion_subnets
}

output "private_app_subnets" {
  description = "List of private app subnet IDs"
  value       = module.network.private_app_subnets
}

output "private_db_subnets" {
  description = "List of private DB subnet IDs"
  value       = module.network.private_db_subnets
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs used by private subnets"
  value       = module.network.nat_gateway_ids
}

output "igw_id" {
  description = "Internet Gateway ID"
  value       = module.network.igw_id
}

# -------------------------
# Active ASG / Capacity
# -------------------------
output "active_asg" {
  description = "Name of currently active ASG"
  value       = var.active_color == "blue" ? module.asg_blue.asg_name : module.asg_green.asg_name
}

output "active_capacity" {
  description = "Desired number of instances in active ASG"
  value       = var.active_color == "blue" ? module.asg_blue.desired_capacity : module.asg_green.desired_capacity
}

# -------------------------
# ASG Blue / Green Info
# -------------------------
output "asg_blue_name" {
  description = "Name of the blue ASG"
  value       = module.asg_blue.asg_name
}

output "asg_green_name" {
  description = "Name of the green ASG"
  value       = module.asg_green.asg_name
}

output "asg_blue_capacity" {
  description = "Desired capacity of blue ASG"
  value       = module.asg_blue.desired_capacity
}

output "asg_green_capacity" {
  description = "Desired capacity of green ASG"
  value       = module.asg_green.desired_capacity
}

# -------------------------
# ALB / WAF / CloudFront
# -------------------------
output "alb_name" {
  description = "Name of ALB"
  value       = module.alb.alb_name
}

output "alb_dns_name" {
  description = "DNS name of ALB"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Hosted zone ID of ALB"
  value       = module.alb.alb_zone_id
}

output "https_listener_arn" {
  description = "HTTPS listener ARN for ALB"
  value       = module.alb.https_listener_arn
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL attached to ALB"
  value       = module.waf_cf.web_acl_arn
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name (if enabled)"
  value       = module.cloudfront.distribution_domain_name
}

# -------------------------
# ECR Info
# -------------------------
output "ecr_repo_url" {
  description = "ECR repository URL"
  value       = module.ecr.repo_url
}

# -------------------------
# IAM Instance Profile
# -------------------------
output "iam_instance_profile" {
  description = "IAM instance profile used by ASG EC2 instances"
  value       = module.iam.instance_profile_name
}

# -------------------------
# HTTPS Service URL
# -------------------------
output "https_url" {
  description = "HTTPS URL of the service via DuckDNS / domain"
  value       = "https://${var.duckdns_domain}"
  sensitive   = true
}
