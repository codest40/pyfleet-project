
output "daily_budget_name" {
  description = "Name of the AWS daily cost budget"
  value       = aws_budgets_budget.daily_budget.name
}

output "cost_alerts_sns_topic_arn" {
  description = "SNS topic ARN for daily cost alerts"
  value       = aws_sns_topic.cost_alerts.arn
}
