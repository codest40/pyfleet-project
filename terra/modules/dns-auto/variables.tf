# -------------------------
# DuckDNS
# -------------------------
variable "duckdns_token" {
  type        = string
  description = "DuckDNS token"
}

variable "duckdns_domain" {
  type        = string
  description = "DuckDNS subdomain to create/update"
}

variable "alb_dns_name" {
  type        = string
  description = "Optional ALB DNS name"
  default     = null
}

variable "alb_zone_id" {
  type        = string
  description = "Optional ALB hosted zone ID"
  default     = null
}

variable "cloudfront_domain" {
  type        = string
  description = "Optional CloudFront domain name"
  default     = null
}

variable "cloudfront_zone" {
  type        = string
  description = "Optional CloudFront hosted zone ID"
  default     = null
}
