# ============================================================
#  DNS AUTOMATION MODULE — PYFLEET
# ============================================================

# ------------------------------------------------------------
#  OVERVIEW
# ------------------------------------------------------------
The DNS Automation module manages dynamic DNS updates for PyFleet
applications. It supports:

- Automatic updates of DuckDNS subdomains pointing to ALB
- Optional AWS Route53 alias records for production-ready DNS


# ------------------------------------------------------------
#  WHAT THIS MODULE CREATES
# ------------------------------------------------------------

## DuckDNS Subdomain Update
- Executes a curl command via `null_resource.local-exec` to
  update the public IP of DuckDNS subdomain automatically
  whenever the ALB or CloudFront DNS changes.

## Optional Route53 Alias Record
- Creates a Route53 A record pointing to either:
  - ALB DNS name, or
  - CloudFront distribution
- Uses AWS alias feature to automatically route traffic to the target.

# ------------------------------------------------------------
#  WHY THIS DESIGN
# ------------------------------------------------------------

## 1. Dynamic Public IP Handling
- Useful for development or small-scale deployments with changing local IPs.

## 2. AWS Integration
- Provides optional Route53 alias for professional, cloud-native DNS routing.

## 3. Learning-Oriented
- Demonstrates `null_resource` and `local-exec` usage for automating external services in Terraform.

# ------------------------------------------------------------
#  HOW IT WORKS
# ------------------------------------------------------------
```
## Inputs
+------------------------+------------------------------------------------+
| Variable               | Description                                    |
+------------------------+------------------------------------------------+
| duckdns_token          | DuckDNS API token                              |
| duckdns_domain         | Subdomain to update (e.g., myapp.duckdns.org) |
| alb_dns_name           | Optional ALB DNS target for Route53 alias     |
| alb_zone_id            | Optional ALB hosted zone ID                    |
| cloudfront_domain      | Optional CloudFront domain target              |
| cloudfront_zone        | Optional CloudFront hosted zone ID             |
+------------------------+------------------------------------------------+
```

## Logic
Determine the DNS target using coalescing logic:
- `dns_target_name = cloudfront_domain if provided, else alb_dns_name`
- `dns_zone_id = cloudfront_zone if provided, else alb_zone_id`

- DuckDNS Update: Triggered via `null_resource.local-exec` whenever ALB or CloudFront DNS changes.
- Route53 Alias Record: Automatically creates a Route53 A record pointing to the target if inputs are provided.

## Traffic Flow
Internet → DuckDNS → Route53 → ALB / CloudFront → PyFleet Application

# ------------------------------------------------------------
#  OUTPUTS
#
``` ------------------------------------------------------------
+------------------+--------------------------------------+
| Output           | Description                          |
+------------------+--------------------------------------+
| duckdns_domain   | DuckDNS subdomain being updated      |
| route53_fqdn     | Fully-qualified domain name of Route53 alias |
+------------------+--------------------------------------+
```
# ------------------------------------------------------------
#  DESIGN NOTES
# ------------------------------------------------------------
- Local Execution: Runs on the machine applying Terraform, not inside AWS.
- Flexible Integration: Supports either ALB or CloudFront targets.
- DNS Safety: Uses coalescing logic to determine correct target, preventing misconfiguration.

# ------------------------------------------------------------
#  SUMMARY
# ------------------------------------------------------------
The DNS Automation module automates dynamic DNS updates for both
local and cloud-hosted PyFleet deployments. It demonstrates
practical integration of external services (DuckDNS) with AWS
infrastructure, reinforcing Infrastructure-as-Code learning and
DevOps automation practices.
