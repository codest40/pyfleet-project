
# -------------------------
# Outputs
# -------------------------
output "regional_cert_arn" {
  value = aws_acm_certificate.regional_cert.arn
}

output "cloudfront_cert_arn" {
  value = aws_acm_certificate.cf_cert.arn
}

