# ============================================================
#  AUTO SCALING GROUP (ASG) MODULE — PYFLEET
# ============================================================

# ------------------------------------------------------------
#  OVERVIEW
# ------------------------------------------------------------
The ASG module provisions EC2 Auto Scaling Groups for PyFleet.

It supports:

- Blue/green deployment environments
- CPU and memory-based auto-scaling
- CloudWatch monitoring and alarms
- Integration with ALB target groups
- Dockerized PyFleet container deployment via ECR

EC2 instances are bootstrapped with a Launch Template that includes IAM roles,
security groups, user data scripts, and CloudWatch agent for memory metrics.

# ------------------------------------------------------------
#  WHAT THIS MODULE CREATES
# ------------------------------------------------------------

## Launch Template
- Base AMI and instance type for EC2 instances
- IAM instance profile for secure access
- Security groups for app and bastion access
- User data script to:
  - Install Docker
  - Pull PyFleet container from ECR
  - Configure systemd service for PyFleet
  - Install CloudWatch agent for memory metrics

## Security Group
- SSH access restricted to bastion host
- Outbound traffic to DB SG allowed
- All other outbound traffic open

## Auto Scaling Group (ASG)
- Deployed across private subnets
- Attached to ALB target group
- Supports min, max, and desired capacity
- Blue/green deployment support via `name_suffix`
- Tags for Name, Project, Environment, and Owner

## Scaling Policies
- CPU-based: high/low thresholds trigger scale-up/down
- Memory-based: high/low thresholds trigger scale-up/down

## CloudWatch Alarms
- Monitors CPU and memory utilization
- Triggers associated scaling policies automatically

# ------------------------------------------------------------
#  WHY THIS DESIGN
# ------------------------------------------------------------

## 1. Blue/Green Deployment
- Separate ASGs per color (blue/green)
- Switch traffic via ALB listener updates
- Enables zero-downtime deployments

## 2. Dynamic Scaling
- Adjusts EC2 capacity based on CPU/memory load
- Provides cost-efficiency and resilience

## 3. Containerized App Deployment
- Launches Docker container from ECR on boot
- Automated systemd service ensures consistent startup

## 4. Observability
- CloudWatch metrics and alarms provide proactive monitoring

# ------------------------------------------------------------
#  HOW IT WORKS
# ------------------------------------------------------------

## Inputs
+-------------------------------+------------------------------------------------+
| Variable                      | Description                                    |
+-------------------------------+------------------------------------------------+
| vpc_id                        | VPC ID for ASG instances                        |
| subnet_ids                     | Private subnet IDs for EC2 placement            |
| security_group_ids             | Security groups attached to EC2 instances      |
| ami                            | AMI ID for EC2 instances                        |
| instance_type                  | EC2 instance type                               |
| key_name                       | SSH key for EC2 instances                        |
| iam_instance_profile_name      | IAM role for EC2 instances                       |
| alb_target_group_arn           | ALB target group ARN for ASG attachment         |
| ecr_repo_url                   | Full ECR repo URL for Docker image              |
| region                         | AWS region (for ECR login)                      |
| asg_name                       | Base ASG name                                   |
| instance_name                  | EC2 Name tag                                    |
| name_suffix                     | Suffix to differentiate ASGs (blue / green)    |
| environment                    | Environment tag (dev, staging, prod)           |
| min_size                        | Minimum ASG size                                 |
| max_size                        | Maximum ASG size                                 |
| desired_capacity                | Desired ASG size                                 |
| cpu_high_threshold              | CPU high threshold for scaling                  |
| cpu_low_threshold               | CPU low threshold for scaling                   |
| cpu_scale_up_adjustment         | CPU scale-up step size                           |
| cpu_scale_down_adjustment       | CPU scale-down step size                         |
| mem_high_threshold              | Memory high threshold for scaling               |
| mem_low_threshold               | Memory low threshold for scaling                |
| mem_scale_up_adjustment         | Memory scale-up step size                        |
| mem_scale_down_adjustment       | Memory scale-down step size                      |
| bastion_sg_id                   | Bastion SG ID for SSH access                     |
| db_security_group_id            | DB SG ID for outbound traffic                    |
+-------------------------------+------------------------------------------------+

## Logic
- **Launch Template**: Prepares EC2 instances with Docker, ECR, and CloudWatch agent; deploys PyFleet container as systemd service
- **ASG**: Launches EC2 instances in private subnets, attaches to ALB target group, applies tags
- **Scaling**: CPU or memory metrics trigger scaling policies; CloudWatch alarms monitor thresholds and invoke ASG actions

## Traffic & Deployment Flow
ALB → Target Group (Blue/Green) → ASG Instances → Docker Container (PyFleet)

- Traffic directed to active target group only
- Separate ASGs per environment or color enable zero-downtime deployment
- Auto-scaling ensures optimal capacity based on load

# ------------------------------------------------------------
#  OUTPUTS
# ------------------------------------------------------------
+-------------------------------+------------------------------------------------+
| Output                        | Description                                    |
+-------------------------------+------------------------------------------------+
| asg_name                       | Name of the ASG                                 |
| asg_arn                        | ARN of the ASG                                  |
| asg_sg_id                       | Security group ID of ASG instances             |
| desired_capacity               | Current desired instance count                  |
| cpu_scale_up_policy_arn         | CPU scale-up policy ARN                          |
| cpu_scale_down_policy_arn       | CPU scale-down policy ARN                        |
| mem_scale_up_policy_arn         | Memory scale-up policy ARN                        |
| mem_scale_down_policy_arn       | Memory scale-down policy ARN                      |
| cpu_high_alarm_name             | CloudWatch alarm for high CPU                     |
| cpu_low_alarm_name              | CloudWatch alarm for low CPU                      |
| mem_high_alarm_name             | CloudWatch alarm for high memory                  |
| mem_low_alarm_name              | CloudWatch alarm for low memory                   |
+-------------------------------+------------------------------------------------+

# ------------------------------------------------------------
#  DESIGN NOTES
# ------------------------------------------------------------
- Blue/Green Deployment Ready: use `name_suffix` to differentiate ASGs
- Proactive Scaling: CPU and memory alarms trigger scaling automatically
- Containerized Workload: runs Docker image directly from ECR
- Private Subnet Deployment: ensures instances are not publicly exposed
- Observability: CloudWatch metrics for CPU and memory enable monitoring and alerting
