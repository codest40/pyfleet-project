================================================================================
#                       MONITORING-COST MODULE
#                 AWS Cost Alerts & Budgets for PyFleet
================================================================================

#  OVERVIEW
# ------------------------------------------------------------
The Monitoring-Cost module sets up daily cost tracking and
notifications for AWS resources in the PyFleet platform.

It creates an AWS Budget and SNS topic to alert when daily
spending approaches or exceeds defined thresholds, enabling
proactive cost governance.

# ------------------------------------------------------------
#  WHAT THIS MODULE CREATES
# ------------------------------------------------------------

## SNS Topic & Subscriptions
- SNS topic for sending cost alert notifications
- Email subscriptions to deliver alerts to specified recipients

## AWS Budget
- Daily cost budget with configurable limit in USD
- Notifications triggered at 40% and 100% of daily budget
- Alerts delivered via the SNS topic/email list

# ------------------------------------------------------------
#  INPUTS
# ------------------------------------------------------------
+------------------------+-----------------------------------------------+----------------+
| Variable               | Description                                   | Default        |
+------------------------+-----------------------------------------------+----------------+
| project_name           | Project tag used for cost allocation          | —              |
| daily_budget_amount    | Daily cost budget in USD                      | —              |
| alert_emails           | List of email addresses to receive alerts    | —              |
| tags                   | Common tags applied to all resources          | —              |
+------------------------+-----------------------------------------------+----------------+

# ------------------------------------------------------------
#  OUTPUTS
# ------------------------------------------------------------
+-------------------------------+------------------------------------------------+
| Output                        | Description                                    |
+-------------------------------+------------------------------------------------+
| daily_budget_name             | Name of the AWS daily cost budget             |
| cost_alerts_sns_topic_arn     | SNS topic ARN for daily cost alerts           |
+-------------------------------+------------------------------------------------+

# ------------------------------------------------------------
#  HOW IT WORKS
# ------------------------------------------------------------
- AWS Budget monitors daily spending and compares actual costs against the budgeted amount
- Notifications are triggered when spending reaches 40% or 100% of the daily budget
- SNS Topic delivers alerts to all subscribed email recipients

# ------------------------------------------------------------
#  USAGE NOTES
# ------------------------------------------------------------
- Provides proactive cost monitoring for AWS resources
- Alerts ensure early detection of spending anomalies
- Multiple email recipients can be added for team-wide notifications
