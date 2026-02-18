
# =======================================================
# ACM MODULE VARIABLES - PYFLEET
# =======================================================

# Domain name for the certificate
variable "domain_name" {
  description = "Domain name for SSL certificate"
  type        = string
}

# tags to attach to ACM certificates
variable "tags" {
  description = "Map of tags to attach to ACM certificates"
  type        = map(string)
  default = {
    Project = "pyfleet"
    Owner   = "DevOps"
    Env     = "dev"
  }
}
