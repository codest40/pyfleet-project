
# =======================================================
# WAF MODULE OUTPUTS v3 - PYFLEET
# =======================================================

output "web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.this.id
}

output "ip_set_admin_arn" {
  description = "ARN of admin IP set (if any)"
  value       = length(aws_wafv2_ip_set.admin) > 0 ? aws_wafv2_ip_set.admin[0].arn : null
}

output "waf_log_group_name" {
  description = "CloudWatch Log Group name for WAF logs"
  value       = length(aws_cloudwatch_log_group.waf_logs) > 0 ? aws_cloudwatch_log_group.waf_logs[0].name : null
}

output "waf_log_group_arn" {
  description = "CloudWatch Log Group ARN for WAF logs"
  value       = length(aws_cloudwatch_log_group.waf_logs) > 0 ? aws_cloudwatch_log_group.waf_logs[0].arn : null
}
