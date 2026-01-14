# =======================================================
# CLOUDFRONT MODULE VARIABLES - PYFLEET
# =======================================================

variable "name" {
  description = "CloudFront distribution name"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name used as CloudFront origin"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate ARN (us-east-1)"
  type        = string
}

variable "web_acl_arn" {
  description = "WAF Web ACL ARN (CLOUDFRONT scope)"
  type        = string
  default     = null
}

variable "allowed_methods" {
  description = "Allowed HTTP methods"
  type        = list(string)
  default     = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "DELETE"]
}

variable "cached_methods" {
  description = "Cached HTTP methods"
  type        = list(string)
  default     = ["GET", "HEAD"]
}

variable "enable_logging" {
  description = "Enable CloudFront CloudWatch logging"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}
