# =========================
# MONITORING OUTPUTS
# =========================

output "target_group_alarm_names" {
  description = "Target group unhealthy alarms"
  value       = keys(aws_cloudwatch_metric_alarm.tg_unhealthy_hosts)
}

output "alb_alarm_names" {
  description = "ALB-related alarm names"
  value = concat(
    aws_cloudwatch_metric_alarm.alb_5xx_errors[*].alarm_name,
    aws_cloudwatch_metric_alarm.alb_latency_p95[*].alarm_name
  )
}

output "asg_alarm_name" {
  description = "ASG capacity alarm name"
  value       = aws_cloudwatch_metric_alarm.asg_insufficient_capacity[*].alarm_name
}

output "sns_topic_arn" {
  description = "SNS topic ARN for monitoring alerts"
  value       = aws_sns_topic.alerts.arn
}

output "alert_email" {
  description = "Email address subscribed to alerts"
  value       = var.alert_email
}

# =========================
# DASHBOARD OUTPUT
# =========================

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.service_dashboard.dashboard_name
}
