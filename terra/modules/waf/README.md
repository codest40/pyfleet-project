# ============================================================
#  WAF MODULE — PYFLEET
# ============================================================

# ------------------------------------------------------------
#  OVERVIEW
# ------------------------------------------------------------
The WAF module creates a Web Application Firewall (WAF) to
protect ALB (REGIONAL) or CloudFront (CLOUDFRONT) distributions
within the PyFleet platform.

It supports rate limiting, admin IP allowlists, country blocking,
and logging to CloudWatch for observability and security.

# ------------------------------------------------------------
#  WHAT THIS MODULE CREATES
# ------------------------------------------------------------

## WAF Web ACL
- Default action: allow all traffic except when rules match
- Rate limiting:
  - /login endpoint limited to a configurable number of requests per 5 minutes
  - API endpoints limited to a configurable number of requests per 5 minutes
- Admin IP allowlist: whitelists trusted IP addresses
- Country blocking: blocks requests from specified countries
- CloudWatch metrics enabled for all rules

## Admin IP Set
- Creates a WAF IP Set for allowed admin IPs

## CloudWatch Logging
- Logs WAF requests to a CloudWatch log group
- Optionally redacts sensitive headers (like Authorization)

# ------------------------------------------------------------
#  INPUTS
# ------------------------------------------------------------
+------------------------+---------------------------------------------------------+----------------+
| Variable               | Description                                             | Default        |
+------------------------+---------------------------------------------------------+----------------+
| name                   | WAF Web ACL name                                        | —              |
| scope                  | WAF scope: REGIONAL (ALB) or CLOUDFRONT (CloudFront)   | —              |
| login_rate_limit       | Max requests per 5 minutes for login endpoint          | —              |
| api_rate_limit         | Max requests per 5 minutes for API endpoints           | —              |
| admin_ip_allowlist     | List of IPs allowed full access                         | —              |
| blocked_countries      | List of ISO country codes to block                      | —              |
| enable_logging         | Enable WAF logging to CloudWatch                        | —              |
| tags                   | Tags applied to all resources                            | —              |
+------------------------+---------------------------------------------------------+----------------+

# ------------------------------------------------------------
#  OUTPUTS
# ------------------------------------------------------------
+------------------------+---------------------------------------------------------+
| Output                 | Description                                             |
+------------------------+---------------------------------------------------------+
| web_acl_arn            | ARN of the WAF Web ACL                                  |
| web_acl_id             | ID of the WAF Web ACL                                   |
| ip_set_admin_arn       | ARN of admin IP set (if any)                             |
| waf_log_group_name     | CloudWatch Log Group name for WAF logs                  |
| waf_log_group_arn      | CloudWatch Log Group ARN for WAF logs                   |
+------------------------+---------------------------------------------------------+

# ------------------------------------------------------------
#  HOW IT WORKS
# ------------------------------------------------------------
- Web ACL rules combine rate limiting, IP allowlist, and country blocking
- Admin IP allowlist uses a WAF IP Set to permit trusted IPs
- CloudWatch Logging sends sampled requests to a log group for monitoring and auditing
- Rate-based rules automatically block IPs that exceed configured thresholds

# ------------------------------------------------------------
#  USAGE NOTES
# ------------------------------------------------------------
- Protect ALB or CloudFront endpoints from abusive traffic
- Keep admin IPs up-to-date for authorized access
- CloudWatch logs provide visibility into blocked or allowed requests
- Supports multiple rules with clear priority ordering for predictable enforcement
