
variable "repo_name" {
  type        = string
  description = "Name of the ECR repository"
  default     = "ecr-pyfleet"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "kms_key_arn" {
  type = string
}

