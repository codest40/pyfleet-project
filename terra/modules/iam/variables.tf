# IAM Role name for EC2
variable "role_name" {
  description = "IAM role name for EC2 instances"
  type        = string
  default     = "ec2-ecr-role"
}

# IAM Instance Profile name for EC2
variable "instance_profile_name" {
  description = "IAM instance profile name for EC2 instances"
  type        = string
  default     = "ec2-ecr-profile"
}

# Managed policy ARN to attach (ECR read-only)
variable "ecr_policy_arn" {
  description = "ARN of the managed policy to attach (ECR read-only)"
  type        = string
  default     = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Optional tags for IAM resources
variable "tags" {
  description = "Optional tags for IAM resources"
  type        = map(string)
  default = {
    "Project" = "pyfleet"
    "Owner"   = "DevOps" # For multi tag purpose
  }
}
