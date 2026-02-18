# ============================================================
#  APPLICATION LOAD BALANCER (ALB) MODULE — PYFLEET
# ============================================================

# ------------------------------------------------------------
#  OVERVIEW
# ------------------------------------------------------------
The ALB module provisions a CloudFront-ready Application Load Balancer
for PyFleet. It supports:

- Blue/green deployment target groups
- HTTPS termination with ACM certificate
- Access logging to S3
- CloudFront-aware security

This module ensures secure, highly-available, and zero-downtime
application ingress.

# ------------------------------------------------------------
#  WHAT THIS MODULE CREATES
# ------------------------------------------------------------

## Security Group
- Allows inbound HTTPS (443) from:
  - AWS-managed CloudFront prefix list
  - Your personal IP (for admin/testing)
- Allows all outbound traffic.

## Application Load Balancer (ALB)
- Internet-facing, deployed across public subnets
- HTTPS termination using ACM certificate
- Access logs sent to dedicated S3 bucket

## Target Groups (Blue / Green)
- Supports blue/green deployments
- Listens on HTTP port 80
- Health checks configured for `/`

## HTTPS Listener
- Routes traffic to active target group based on input `active_color`
- Can enforce HTTP → HTTPS redirection rules

## ALB Logging
- Stores access logs in specified S3 bucket with optional prefix

# ------------------------------------------------------------
#  WHY THIS DESIGN
# ------------------------------------------------------------

## 1. Blue/Green Deployment
- Enables zero-downtime deployments by switching traffic between two target groups

## 2. CloudFront Security Awareness
- Restricts inbound HTTPS traffic to CloudFront prefix list + admin IP

## 3. Auditable Logs
- S3-based access logs provide security auditing and monitoring

## 4. Flexible Integration
- Works with ACM module for SSL
- Compatible with CloudFront module for CDN distribution
- Integrates with ASG module for EC2 app server registration

# ------------------------------------------------------------
#  HOW IT WORKS
# ------------------------------------------------------------
```
## Inputs
+--------------------+------------------------------------------------------+
| Variable           | Description                                          |
+--------------------+------------------------------------------------------+
| vpc_id             | ID of the VPC where ALB is deployed                 |
| public_subnets     | Public subnets for ALB placement                     |
| alb_sg_name        | Name for the ALB security group                      |
| alb_name           | Name of the ALB                                      |
| tg_name            | Base name for target groups (blue / green)          |
| certificate_arn    | ACM certificate ARN for HTTPS                        |
| active_color       | Target group receiving traffic (blue or green)       |
| alb_logs_bucket    | S3 bucket to store ALB access logs                   |
| alb_logs_prefix    | Optional S3 prefix for logs                           |
| my_ip              | Personal IP for admin access                          |
| tags               | Common tags applied to all resources                  |
+--------------------+------------------------------------------------------+
```

## Logic
- **CloudFront Prefix List**: Uses AWS-managed prefix list to restrict HTTPS access
- **Security Group**: Combines CloudFront CIDRs + admin IP
- **ALB & Target Groups**:
  - ALB listens on HTTPS (443) and routes traffic to active target group
  - Two target groups (blue / green) support blue/green deployment
- **HTTPS Listener**:
  - Uses provided ACM certificate
  - Default action forwards to active target group
- **ALB Logging**:
  - Logs requests to S3 bucket under specified prefix

## Traffic Flow Diagram
Internet → CloudFront → ALB (HTTPS) → Target Group (Blue/Green) → EC2 App Servers

```
# ------------------------------------------------------------
#  OUTPUTS
# ------------------------------------------------------------
+------------------------+------------------------------------------------+
| Output                 | Description                                    |
+------------------------+------------------------------------------------+
| alb_name               | Name of the ALB                                |
| alb_sg_id              | Security group ID of the ALB                   |
| alb_dns_name           | DNS name of the ALB                             |
| alb_zone_id            | Hosted zone ID of the ALB                       |
| web_tg_blue_arn        | ARN of the blue target group                    |
| web_tg_green_arn       | ARN of the green target group                   |
| https_listener_arn     | ARN of the HTTPS listener                        |
| alb_logs_bucket        | S3 bucket storing ALB logs                        |
| web_alb_arn            | ARN of the ALB                                   |
| alb_logs_prefix        | S3 prefix for ALB logs                           |
+------------------------+------------------------------------------------+
```
# ------------------------------------------------------------
#  DESIGN NOTES
# ------------------------------------------------------------
- Blue/Green Support: Toggle traffic by changing `active_color`
- CloudFront Integration: Only CloudFront IPs + admin IP can access HTTPS
- ALB Logs: Detailed request insights for monitoring and auditing
- Extensible: Can integrate with WAF, CloudFront, and ASG modules seamlessly
