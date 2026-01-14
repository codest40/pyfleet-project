# =======================================================
# WAF MODULE VARIABLES v3 - PYFLEET
# =======================================================

variable "name" {
  type        = string
  description = "WAF Web ACL name"
}

variable "scope" {
  type        = string
  description = "WAF scope: REGIONAL or CLOUDFRONT"
}

variable "login_rate_limit" {
  type        = number
  description = "Rate limit for /login"
  default     = 50
}

variable "api_rate_limit" {
  type        = number
  description = "Rate limit for API endpoints"
  default     = 500
}

variable "admin_ip_allowlist" {
  type        = list(string)
  description = "List of admin IPs allowed"
  default     = []
}

variable "blocked_countries" {
  type        = list(string)
  description = "List of countries to block"
  default     = []
}

variable "enable_logging" {
  type        = bool
  description = "Enable WAF logging to CloudWatch"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags for all WAF resources"
  default     = {}
}
