# =======================================================
# ROOT MODULE VARIABLES (pyfleet v2)
# =======================================================

# -------------------------
# General / Region
# -------------------------
variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"
}

# -------------------------
# ASG / Blue-Green Deployment
# -------------------------
variable "active_color" {
  description = "Which ASG should receive traffic: blue or green"
  type        = string
}

variable "required_capacity" {
  description = "Desired number of instances for the active ASG"
  type        = number
  default     = 2
}

# -------------------------
# DuckDNS / Domain
# -------------------------
variable "duckdns_token" {
  description = "DuckDNS API token"
  type        = string
  sensitive   = true
}

variable "duckdns_domain" {
  description = "DuckDNS domain"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "Custom domain name for ACM / CloudFront"
  type        = string
  sensitive   = true
}

# -------------------------
# SSH / IAM
# -------------------------
variable "key" {
  description = "SSH key name for EC2 instances"
  type        = string
  sensitive   = true
}

variable "my_email" {
  description = "Email for monitoring/alerts"
  type        = string
  sensitive   = true
}

variable "alert_emails" {
  description = "List of emails for cost or SRE alerts"
  type        = list(string)
  sensitive   = false
}

# -------------------------
# Budget
# -------------------------
variable "budget_amount" {
  description = "Daily budget amount for cost monitoring"
  type        = number
  sensitive   = true
}

# -------------------------
# Bastion Section
# -------------------------
variable "bastion_ami" {
  description = "AMI ID for bastion host"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
  default     = "t3.micro"
}

variable "my_ip_cidr" {
  description = "Current public IP in CIDR format"
  type        = string
}

# -------------------------
# Database Section
# -------------------------
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "pyfleet-db"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "pyfleet-db-user"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

# -------------------------
# Project Tags
# -------------------------
variable "project_name" {
  description = "Project tag applied to all resources"
  type        = string
  default     = "pyfleet"
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default = {
    Project = "pyfleet"
    Owner   = "DevOps"
    Env     = "dev"
  }
}

variable "us_east_1_cert_arn" {
  description = "ACM certificate ARN for CloudFront (must be in us-east-1)"
  type        = string
}

variable "app_ami" {
  description = "AMI ID for app servers in ASG"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for ASG"
  type        = string
  default     = "t2.micro"
}

variable "env" {
  description = "Environment tag value"
  type        = string
  default     = "dev"
}



