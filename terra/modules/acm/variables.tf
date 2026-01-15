
# =======================================================
# ACM MODULE VARIABLES - PYFLEET
# =======================================================

# Domain name for the certificate (e.g., duckdns or custom domain)
variable "domain_name" {
  description = "Domain name for SSL certificate (e.g., app.duckdns.org)"
  type        = string
}

# Optional tags to attach to ACM certificates
variable "tags" {
  description = "Map of tags to attach to ACM certificates"
  type        = map(string)
  default = {
    Project = "pyfleet"
    Owner   = "DevOps"
    Env     = "dev"
  }
}
