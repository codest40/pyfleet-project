# =======================================================
# ALB MODULE VARIABLES - PYFLEET
# =======================================================

variable "my_ip" {
  description = "My local Ip for testing"
  type        = list(string)
  default     = ["105.117.11.54/32"]
}

# VPC ID 
variable "vpc_id" {
  description = "ID of the VPC where the ALB will be created"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets to deploy the ALB"
  type        = list(string)
}

variable "alb_sg_name" {
  description = "ALB security group name"
  type        = string
  default     = "pyfleet-alb-sg"
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "pyfleet-alb"
}

variable "tg_name" {
  description = "Base name for ALB target groups"
  type        = string
  default     = "pyfleet-tg"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
}

variable "active_color" {
  description = "Which target group receives traffic: blue or green"
  type        = string
  default     = "blue"
}

variable "alb_logs_bucket" {
  description = "S3 bucket for ALB access logs"
  type        = string
}

variable "alb_logs_prefix" {
  description = "Prefix inside S3 bucket for ALB logs"
  type        = string
  default     = "alb-logs"
}

variable "tags" {
  description = "Common tags applied to all ALB resources"
  type        = map(string)
  default = {
    Project = "pyfleet"
    Owner   = "DevOps"
    Env     = "dev"
  }
}
