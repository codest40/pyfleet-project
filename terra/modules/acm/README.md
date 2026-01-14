# ============================================================
#  ACM MODULE — PYFLEET
# ============================================================

# ------------------------------------------------------------
#  OVERVIEW
# ------------------------------------------------------------
The ACM (AWS Certificate Manager) module provisions SSL/TLS 
certificates for secure communication across the PyFleet platform.

It supports both regional and global use cases:

- Regional certificate for the ALB (Application Load Balancer)
- Global certificate for CloudFront (must reside in us-east-1)

This module ensures end-to-end HTTPS for PyFleet.

# ------------------------------------------------------------
#  WHAT THIS MODULE CREATES
# ------------------------------------------------------------

## Regional ACM Certificate
- Used by the ALB to terminate HTTPS traffic at the edge of the VPC
- Validated via DNS (preferred for automation)

## CloudFront ACM Certificate
- Required for serving traffic over HTTPS from CloudFront distributions
- Must be issued in the us-east-1 region (AWS requirement)
- Validated via DNS

# ------------------------------------------------------------
#  WHY THIS DESIGN
# ------------------------------------------------------------

## Separation of Concerns
- Regional certificate handles internal ALB traffic
- CloudFront certificate handles global CDN traffic

## AWS Requirements Compliance
- CloudFront only accepts ACM certificates in us-east-1

## Automation-Friendly
- Fully DNS-validated for zero-touch issuance
- Tags applied for cost tracking and resource ownership

# ------------------------------------------------------------
#  HOW IT WORKS
# ------------------------------------------------------------

## Inputs
| Variable     | Description                                |
|-------------|--------------------------------------------|
| domain_name  | Fully-qualified domain name (FQDN)        |
| tags         | Optional tags for environment/project      |

## Certificate Creation
- `aws_acm_certificate.regional_cert` → ALB
- `aws_acm_certificate.cf_cert` → CloudFront (us-east-1 provider alias)

## DNS Validation
- Certificates use DNS validation
- Automation can attach Route53 or external DNS records

# ------------------------------------------------------------
#  OUTPUTS
# ------------------------------------------------------------
| Output               | Description                                      |
|---------------------|--------------------------------------------------|
| regional_cert_arn    | ARN of the ACM certificate for ALB             |
| cloudfront_cert_arn  | ARN of the ACM certificate for CloudFront      |

**Consumed by:**
- ALB module → HTTPS listener
- CloudFront module → distribution certificate

# ------------------------------------------------------------
#  DESIGN NOTES & BEST PRACTICES
# ------------------------------------------------------------
- **Provider Alias:** CloudFront certificate explicitly provisioned in us-east-1
- **DNS Validation:** Enables automated CI/CD workflows
- **Tagging:** Supports environment/project-level clarity and cost tracking

# ------------------------------------------------------------
#  SUMMARY
# ------------------------------------------------------------
Centralizes certificate management for PyFleet, enabling:

- Secure HTTPS traffic within AWS regions (ALB)
- Global HTTPS delivery via CloudFront
- Fully automated DNS-validated provisioning
