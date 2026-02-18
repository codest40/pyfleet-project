# =======================================================
# NETWORK MODULE VARIABLES - PYFLEET
# =======================================================

# -------------------------
# VPC
# -------------------------
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# -------------------------
# Availability Zones and Subnets
# -------------------------
variable "azs" {
  description = "List of AZs with CIDR blocks for public/private subnets"
  type = list(object({
    name           = string
    public_bastion = string
    public_alb     = string
    private_app    = string
    private_db     = string
  }))
}

# -------------------------
# NAT Gateways
# -------------------------
variable "enable_nat" {
  description = "Enable NAT Gateways for private subnets"
  type        = bool
  default     = true
}

# -------------------------
# Tags
# -------------------------
variable "tags" {
  description = "Common tags applied to all network resources"
  type        = map(string)
  default = {
    Project = "pyfleet"
    Env     = "dev"
    Owner   = "DevOps"
  }
}
