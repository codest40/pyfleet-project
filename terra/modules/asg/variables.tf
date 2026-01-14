# =======================================================
# ASG Module v2 - Variables
# =======================================================
# - Supports CPU + Memory based auto-scaling
# - Blue/Green deployment compatible
# =======================================================

# -------------------------
# Networking
# -------------------------
variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for ASG instances"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs attached to EC2 instances"
  type        = list(string)
}

# -------------------------
# Launch Template
# -------------------------
variable "ami" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "SSH key name for EC2 instances"
  type        = string
}

# -------------------------
# Auto Scaling Group sizing
# -------------------------
variable "min_size" {
  description = "Minimum number of EC2 instances"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of EC2 instances"
  type        = number
  default     = 2
}

variable "desired_capacity" {
  description = "Desired number of EC2 instances"
  type        = number
  default     = 1
}

# -------------------------
# Load Balancer
# -------------------------
variable "alb_target_group_arn" {
  description = "ARN of ALB target group attached to ASG"
  type        = string
}

# -------------------------
# ECR / Docker
# -------------------------
variable "ecr_repo_url" {
  description = "Full ECR repository URL (no tag)"
  type        = string
}

variable "region" {
  description = "AWS region (used for ECR authentication)"
  type        = string
}

# -------------------------
# IAM
# -------------------------
variable "iam_instance_profile_name" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
}

# -------------------------
# Naming / Environment
# -------------------------
variable "asg_name" {
  description = "Base name for the Auto Scaling Group"
  type        = string
  default     = "web-asg-v2"
}

variable "instance_name" {
  description = "EC2 Name tag value"
  type        = string
  default     = "web-asg-v2-instance"
}

variable "name_suffix" {
  description = "Suffix to differentiate ASGs (e.g. blue / green)"
  type        = string
}

variable "environment" {
  description = "Environment tag (dev / staging / prod)"
  type        = string
  default     = "dev"
}

# -------------------------
# CPU Auto Scaling
# -------------------------
variable "cpu_high_threshold" {
  description = "CPU % above which ASG scales up"
  type        = number
  default     = 70
}

variable "cpu_low_threshold" {
  description = "CPU % below which ASG scales down"
  type        = number
  default     = 30
}

variable "cpu_scale_up_adjustment" {
  description = "Number of instances to ADD on CPU scale-up"
  type        = number
  default     = 1
}

variable "cpu_scale_down_adjustment" {
  description = "Number of instances to REMOVE on CPU scale-down"
  type        = number
  default     = 1
}

# -------------------------
# Memory Auto Scaling
# -------------------------
variable "mem_high_threshold" {
  description = "Memory % above which ASG scales up"
  type        = number
  default     = 80
}

variable "mem_low_threshold" {
  description = "Memory % below which ASG scales down"
  type        = number
  default     = 30
}

variable "mem_scale_up_adjustment" {
  description = "Number of instances to ADD on Memory scale-up"
  type        = number
  default     = 1
}

variable "mem_scale_down_adjustment" {
  description = "Number of instances to REMOVE on Memory scale-down"
  type        = number
  default     = 1
}

# -------------------------
# Bastion SG
# -------------------------
variable "bastion_sg_id" {
  description = "Security group ID of the bastion host (for SSH access)"
  type        = string
}

# -------------------------
# DB SG
# -------------------------
variable "db_security_group_id" {
  description = "DB security group ID to allow outbound traffic"
  type        = string
  default     = ""
}
