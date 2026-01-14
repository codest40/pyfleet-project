
variable "vpc_id" {
  description = "VPC where bastion will be launched"
  type        = string
}

variable "my_ip_cidr" {
  description = "Your public IP CIDR to allow SSH (e.g., 1.2.3.4/32)"
  type        = string
}

variable "ami" {
  description = "AMI for bastion host"
  type        = string
}

variable "instance_type" {
  description = "Instance type for bastion"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key name"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnets where bastion will be launched (multi-AZ)"
  type        = list(string)
}
