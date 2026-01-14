# -------------------------
# ACM Certificate
# -------------------------
# -------------------------
# ACM Certificate for ALB (regional)
# -------------------------
resource "aws_acm_certificate" "regional_cert" {
  provider           = aws
  domain_name        = var.domain_name
  validation_method  = "DNS"
  tags               = merge(var.tags, { Name = "alb-cert" })
}

# -------------------------
# ACM Certificate for CloudFront (must be us-east-1)
# -------------------------
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_acm_certificate" "cf_cert" {
  provider           = aws.us_east_1
  domain_name        = var.domain_name
  validation_method  = "DNS"
  tags               = merge(var.tags, { Name = "cloudfront-cert" })
}

