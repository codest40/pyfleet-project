# ============================================================
#  CLOUDFRONT MODULE — PYFLEET
# ============================================================

# ------------------------------------------------------------
#  OVERVIEW
# ------------------------------------------------------------
The CloudFront module provisions a CloudFront distribution
in front of an ALB for the PyFleet platform.

It enables:

- HTTPS access with ACM certificates
- Optional CloudWatch logging
- Integration with WAF Web ACLs
- IPv6 support
- Configurable HTTP methods and caching behavior

This module ensures low-latency, secure, and globally available
access to PyFleet applications.

# ------------------------------------------------------------
#  WHAT THIS MODULE CREATES
# ------------------------------------------------------------

## CloudFront Distribution
- Uses the ALB as origin
- Enforces HTTPS for viewers (HTTP → HTTPS redirect)
- Supports IPv6
- Configurable allowed HTTP methods for viewers
- Configurable cached HTTP methods
- Optional WAF Web ACL attachment
- Price class: PriceClass_100 (low-cost edge locations)

## CloudWatch Log Group (Optional)
- Created if `enable_logging = true`
- Logs CloudFront access events
- Retention: 90 days
- Tagged with Purpose=CloudFront logs

# ------------------------------------------------------------
#  INPUTS
#
``` ------------------------------------------------------------
+-----------------------+----------------------------------------------------+
| Variable              | Description                                        |
+-----------------------+----------------------------------------------------+
| name                  | Name of the CloudFront distribution               |
| alb_dns_name          | DNS name of the ALB used as origin                |
| certificate_arn       | ACM certificate ARN (must be in us-east-1)       |
| web_acl_arn           | Optional WAF Web ACL ARN for CloudFront          |
| allowed_methods       | List of allowed HTTP methods for viewers         |
| cached_methods        | List of HTTP methods cached by CloudFront        |
| enable_logging        | Boolean to enable CloudWatch logging (default: true) |
| tags                  | Map of tags applied to all CloudFront resources  |
+-----------------------+----------------------------------------------------+
```
# ------------------------------------------------------------
#  OUTPUTS
#
``` ------------------------------------------------------------
+-------------------------------+---------------------------------------------+
| Output                        | Description                                 |
+-------------------------------+---------------------------------------------+
| distribution_id                | ID of the CloudFront distribution           |
| distribution_domain_name       | Domain name of the CloudFront distribution |
| distribution_arn               | ARN of the CloudFront distribution          |
| cf_log_group_name              | Name of the CloudWatch log group (if enabled) |
| cf_log_group_arn               | ARN of the CloudWatch log group (if enabled) |
+-------------------------------+---------------------------------------------+
```
# ------------------------------------------------------------
#  HOW IT WORKS
# ------------------------------------------------------------
- The ALB is used as the origin with HTTPS-only access enforced
- Viewer requests are redirected to HTTPS if needed
- CloudFront caches content based on specified allowed and cached methods
- Optional CloudWatch logging captures access logs for monitoring
- Optional WAF Web ACL enforces security policies at the edge

# ------------------------------------------------------------
#  USAGE NOTES
# ------------------------------------------------------------
- Designed to provide a CloudFront CDN in front of a regional ALB
- Enable logging to track requests, detect anomalies, or integrate with monitoring dashboards
- Ensure the ACM certificate ARN is from the us-east-1 region
- Use the distribution domain name as the public endpoint for applications
