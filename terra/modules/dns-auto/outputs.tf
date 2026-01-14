
output "duckdns_domain" {
  description = "DuckDNS subdomain being updated"
  value       = var.duckdns_domain
}

output "route53_fqdn" {
  description = "Route53 FQDN if created (ALB or CloudFront)"
  value       = aws_route53_record.dns_record[*].fqdn
}
