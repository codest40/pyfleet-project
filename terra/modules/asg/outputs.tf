# =======================================================
# ASG Module v2 - Outputs
# =======================================================
# - Exposes ASG identity
# - Exposes scaling policies
# - Exposes CloudWatch alarms for observability
# =======================================================

# -------------------------
# Auto Scaling Group
# -------------------------
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.name
}

output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.arn
}

output "asg_sg_id" {
  description = "Security group ID of the ASG"
  value       = aws_security_group.asg_sg.id
}

output "desired_capacity" {
  description = "Desired number of instances in the ASG"
  value       = aws_autoscaling_group.web_asg.desired_capacity
}

# -------------------------
# CPU Scaling Policies
# -------------------------
output "cpu_scale_up_policy_arn" {
  description = "ARN of the CPU scale-up policy"
  value       = aws_autoscaling_policy.cpu_scale_up.arn
}

output "cpu_scale_down_policy_arn" {
  description = "ARN of the CPU scale-down policy"
  value       = aws_autoscaling_policy.cpu_scale_down.arn
}

# -------------------------
# Memory Scaling Policies
# -------------------------
output "mem_scale_up_policy_arn" {
  description = "ARN of the Memory scale-up policy"
  value       = aws_autoscaling_policy.mem_scale_up.arn
}

output "mem_scale_down_policy_arn" {
  description = "ARN of the Memory scale-down policy"
  value       = aws_autoscaling_policy.mem_scale_down.arn
}

# -------------------------
# CloudWatch Alarms
# -------------------------
output "cpu_high_alarm_name" {
  description = "CloudWatch alarm name for high CPU utilization"
  value       = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
}

output "cpu_low_alarm_name" {
  description = "CloudWatch alarm name for low CPU utilization"
  value       = aws_cloudwatch_metric_alarm.cpu_low.alarm_name
}

output "mem_high_alarm_name" {
  description = "CloudWatch alarm name for high memory utilization"
  value       = aws_cloudwatch_metric_alarm.mem_high.alarm_name
}

output "mem_low_alarm_name" {
  description = "CloudWatch alarm name for low memory utilization"
  value       = aws_cloudwatch_metric_alarm.mem_low.alarm_name
}
