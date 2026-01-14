
output "distribution_id" {
  value = aws_cloudfront_distribution.this.id
}

output "distribution_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "distribution_arn" {
  value = aws_cloudfront_distribution.this.arn
}

output "cf_log_group_name" {
  description = "CloudWatch log group for CloudFront access logs"
  value       = length(aws_cloudwatch_log_group.cf_logs) > 0 ? aws_cloudwatch_log_group.cf_logs[0].name : null
}

output "cf_log_group_arn" {
  description = "CloudWatch log group ARN for CloudFront access logs"
  value       = length(aws_cloudwatch_log_group.cf_logs) > 0 ? aws_cloudwatch_log_group.cf_logs[0].arn : null
}
