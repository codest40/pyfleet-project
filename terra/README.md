--------------------------------------------------------------------------------
#  PyFleet Project  - Terraform AWS Infrastructure
--------------------------------------------------------------------------------
### Overview:

PyFleet Project (Terraform + AWS) is an AWS-based platform deployment project demonstrating
DevOps, SRE, and Platform Engineering best practices. The infrastructure is
modular, reusable, and fully automated with Terraform, providing:

  - EC2-based web application deployment (pyfleet app) in private subnets
  - Blue-Green deployment with ALB 
  - ALB integrated with WAF rules & optional CloudFront
  - Postgres RDS primary + read replicas
  - Secure app-to-DB connectivity via dedicated Security Groups
  - Monitoring, alarms, dashboards
  - Cost alerts and budgets
  - IAM, ECR, DNS automation
  - CloudWatch dashboards and SNS alerts
  - NAT gateway for private subnet egress
  - Integration with DuckDNS or Route53

--------------------------------------------------------------------------------
## Project Architecture:
--------------------------------------------------------------------------------
                               +---------------------+
                               |       Users         |
                               +----------+----------+
                                          |
                                          v
                               +---------------------+
                               |      CloudFront     |
                               +----------+----------+
                                          |
                               +---------------------+
                               |  Application Load   |
                               |      Balancer       |
                               |  (HTTPS/WAF enabled)|
                               |  ( HTTP Redirect )  |
                               |   (   Logs s3  )    |
                               +----------+----------+
                                          |
                 +------------------------+------------------------+
                 |                                                 |
       +---------v---------+                             +---------v---------+
       |   Blue Target     |                             |   Green Target    |
       |  Group (ALB TG)  |                             |  Group (ALB TG)  |
       +---------+---------+                             +---------+---------+
                 |                                                 |
        +--------v--------+                               +--------v--------+
        |   ASG (EC2)     |                               |   ASG (EC2)     |
        |  LaunchTemplate |                               |  LaunchTemplate |
        | Private Subnets |                               | Private Subnets |
        +--------+--------+                               +--------+--------+
                 |                                                 |
                 +------------------+------------------------------+
                                    |
                          +---------v---------+
                          |   Docker on EC2    |
                          | pyfleet containers |
                          +---------+---------+
                                    |
                          +---------v---------+
                          |  Postgres RDS      |
                          |  Primary + Replica |
                          |  Private Subnets   |
                          |  App SG access only|
                          +---------+---------+
                                    |
                          +---------v---------+
                          |  NAT Gateway       |
                          | Outbound Internet  |
                          +-------------------+

---
### Other AWS components:

  - IAM Roles & Instance Profiles
  - ECR repository for Docker image storage
  - ACM certificate for HTTPS
  - WAF Web ACL with rate-limiting & IP restrictions
  - CloudFront distribution (optional) for caching & DDoS protection
  - DuckDNS updater / optional Route53 integration
  - CloudWatch alarms and dashboards
  - SNS topics for alerts
  - AWS daily cost budgets

--------------------------------------------------------------------------------
## Modules Overview:
--------------------------------------------------------------------------------
  1. IAM Module
      - aws_iam_role for EC2
      - aws_iam_instance_profile
      - Policy attachment (ECR read-only)
  
  2. ALB Module
      - aws_lb (Application Load Balancer)
      - Security Group for ALB (HTTP/HTTPS)
      - Blue-Green target groups
      - HTTP→HTTPS redirect
      - HTTPS listener with ACM certificate
      - WAF Web ACL integration (rate limiting, IP bans)
      - Optional CloudFront distribution
      - Access logs enabled in S3

  3. ACM Module
      - aws_acm_certificate for HTTPS
      - Manual DuckDNS validation
      - Outputs certificate ARN

  4. ASG Module
      - aws_launch_template for EC2 configuration
      - IAM instance profile, security groups, user-data Docker setup
      - aws_autoscaling_group with blue/green support
      - Private subnets, NAT egress
      - Health checks and target group attachment

  5. DNS-Auto Module
      - null_resource DuckDNS updater
      - Optional Route53 alias record for ALB
      - Handles dynamic ALB DNS updates

  6. DB Module
      - Primary Postgres RDS instance
      - Multi-AZ support for high availability
      - Read replicas for scaling reads
      - DB Subnet Group in private subnets
      - App Security Group access only
      - Automated backups enabled
      - Tags for environment & role

  7. Monitoring Module
      - CloudWatch metric alarms for:
          - ALB 5XX errors
          - Target group unhealthy hosts
          - ASG capacity drop
          - ALB latency p95
      - CloudWatch dashboard
      - SNS email notifications

  8. ECR Module
      - AWS ECR repository for pyfleet Docker images
      - Lifecycle policy: keep last 10 images
      - Outputs repo URL

  9. Monitoring-Cost Module
      - Daily AWS cost budgets
      - SNS alerts to email addresses
      - Tracks actual and forecasted costs

--------------------------------------------------------------------------------
## Variables & Inputs:
--------------------------------------------------------------------------------
  # DB Module
  - vpc_id                : string
  - private_subnet_ids    : list(string)
  - app_security_group_ids: list(string)
  - db_username           : string
  - db_password           : string
  - db_instance_class     : string
  - db_allocated_storage  : number
  - multi_az              : bool
  - engine_version        : string
  - replica_count         : number
  - tags                  : map(string)

  # (Each Module has its README documented)

--------------------------------------------------------------------------------
## Outputs:
--------------------------------------------------------------------------------
  - DB primary endpoint
  - DB replica endpoints (list)
  - DB security group ID
  - IAM instance profile name
  - ALB name, DNS, listener ARNs, SG ID
  - WAF Web ACL ARN
  - CloudFront distribution ID & domain
  - ACM certificate ARN
  - Target group ARNs (blue & green)
  - ASG names, desired capacities
  - ECR repository URL
  - DuckDNS domain & Route53 FQDN
  - CloudWatch alarm names & dashboard
  - SNS topic ARNs (monitoring + cost)
  - NAT Gateway ID
  - Daily budget name

--------------------------------------------------------------------------------
## Notes:
--------------------------------------------------------------------------------
- Blue-Green deployment: Switch traffic by changing `active_color` variable.
- User Data: Docker container is installed and auto-started via systemd.
- ACM: Validate certificate via DuckDNS or Route53 manually.
- CloudFront: Optional distribution for caching, WAF, and DDoS protection.
- WAF: Rate limiting and IP restrictions configured.
- CloudWatch: All key metrics are monitored, alerts sent via SNS.
- NAT Gateway: Private subnet instances can access the internet securely.
- Postgres DB: Primary + read replicas with secure app-only access
- Automated backups: Enabled for primary DB to support replicas
- Cost Control: Daily budgets to prevent surprises.
- Tags: Consistently applied for ownership & cost tracking.
- Still Expandable: Add new ASGs, ALBs, or target groups easily via modules.

--------------------------------------------------------------------------------
## Summary:
--------------------------------------------------------------------------------
 This is a **modular AWS project**, suitable for demonstrating:
- Terraform infrastructure automation
- DevOps/SRE/Platform Engineering practices
- Blue-Green deployment
- Postgres database scaling with read replicas
- Secure network design with private subnets
- Monitoring and alerting best practices
- Cost governance in AWS
- WAF & CloudFront security at the edge
- Private subnet EC2 deployment with NAT egress
