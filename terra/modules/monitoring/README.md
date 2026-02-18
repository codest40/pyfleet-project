# ============================================================
#  MONITORING MODULE — PYFLEET
# ============================================================

# ------------------------------------------------------------
#  OVERVIEW
# ------------------------------------------------------------
The Monitoring module sets up CloudWatch alarms and a dashboard
to track the health and performance of the Application Load
Balancer (ALB), target groups, and Auto Scaling Groups (ASG).

It also provisions an SNS topic to notify of any critical events,
enabling proactive monitoring and alerting for the PyFleet platform.

# ------------------------------------------------------------
#  WHAT THIS MODULE CREATES
# ------------------------------------------------------------

## CloudWatch Alarms
- Target Group Health: Monitors unhealthy hosts per target group
- ALB 5XX Errors: Triggers when ALB returns 5XX responses above threshold
- ALB Latency (p95): Alerts if response times exceed configurable limits
- ASG Capacity: Detects insufficient InService instances in the Auto Scaling Group

## SNS Topic & Subscriptions
- SNS topic created for sending monitoring alerts
- Email subscription to receive alarm notifications

## CloudWatch Dashboard
- Visualizes ALB metrics (request count, 5XX errors, latency)
- Shows target group health (healthy/unhealthy hosts)
- Tracks ASG InService capacity

# ------------------------------------------------------------
#  INPUTS
#
``` ------------------------------------------------------------
+----------------------------+-----------------------------------------------+----------------+
| Variable                   | Description                                   | Default        |
+----------------------------+-----------------------------------------------+----------------+
| project_name               | Project name used in alarm names and tags     | pyfleet        |
| environment                | Environment name (dev/staging/prod)          | —              |
| tags                       | Common tags applied to all monitoring resources| —             |
| alb_name                   | Name of the Application Load Balancer        | —              |
| target_groups              | Map of target groups (ARN + name) to monitor | —              |
| asg_name                   | Name of the active Auto Scaling Group        | —              |
| enable_alerts              | Whether to enable CloudWatch alarms          | true           |
| sns_topic_arn              | Optional ARN for existing SNS topic          | null           |
| alert_email                | Email address to receive alerts              | —              |
| alb_5xx_threshold          | Threshold of ALB 5XX errors per minute       | 5              |
| unhealthy_host_threshold   | Number of unhealthy targets that triggers alarm | 1           |
| dashboard_name             | Name of the CloudWatch dashboard             | —              |
+----------------------------+-----------------------------------------------+----------------+
```
# ------------------------------------------------------------
#  OUTPUTS
#
``` ------------------------------------------------------------
+----------------------------+------------------------------------------------+
| Output                     | Description                                    |
+----------------------------+------------------------------------------------+
| target_group_alarm_names   | List of target group unhealthy alarms         |
| alb_alarm_names            | List of ALB-related alarms (5XX, latency)    |
| asg_alarm_name             | Name of ASG capacity alarm                    |
| sns_topic_arn              | ARN of the SNS topic for monitoring alerts   |
| alert_email                | Email address subscribed to alerts           |
| dashboard_name             | Name of the CloudWatch dashboard             |
+----------------------------+------------------------------------------------+
```
# ------------------------------------------------------------
#  HOW IT WORKS
# ------------------------------------------------------------
- CloudWatch Alarms monitor key metrics for ALB, target groups, and ASG
- SNS Topic sends alerts for triggered alarms to the specified email
- CloudWatch Dashboard aggregates metrics for quick visibility into service health
- Alarms are optional and can be disabled using `enable_alerts`

# ------------------------------------------------------------
#  USAGE NOTES
# ------------------------------------------------------------
- Use this module to maintain proactive monitoring for applications behind ALB and ASG
- Email alerts ensure rapid notification of issues
- Dashboard visualizes real-time metrics to simplify operational decision-making
- Multi-target group support enables blue/green or multiple deployment strategies
