# -------------------------
# SNS Topic for Cost Alerts
# -------------------------
resource "aws_sns_topic" "cost_alerts" {
  name = "${var.project_name}-daily-cost-alerts"
  tags = var.tags
}

resource "aws_sns_topic_subscription" "email" {
  for_each  = toset(var.alert_emails)
  topic_arn = aws_sns_topic.cost_alerts.arn
  protocol  = "email"
  endpoint  = each.value
}

# -------------------------
# AWS Budget (Daily)
# -------------------------


resource "aws_budgets_budget" "daily_budget" {
  name         = "${var.project_name}-daily-budget"
  budget_type  = "COST"
  time_unit    = "DAILY"
  limit_amount = var.daily_budget_amount
  limit_unit   = "USD"

  # Optional: basic service filter (tags are not allowed)
  cost_types {
    include_credit             = true
    include_discount           = true
    include_other_subscription = true
    include_recurring          = true
    include_refund             = true
    include_subscription       = true
    include_support            = true
    include_tax                = true
    include_upfront            = true
    use_amortized              = false
    use_blended                = false
  }

  notification {
    notification_type          = "ACTUAL"
    comparison_operator        = "GREATER_THAN"
    threshold                  = 40
    threshold_type             = "PERCENTAGE"
    subscriber_email_addresses = var.alert_emails
  }

  notification {
    notification_type          = "ACTUAL"
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    subscriber_email_addresses = var.alert_emails
  }

  tags = var.tags
}
