# =======================================================
# ALB MODULE OUTPUTS - PYFLEET
# =======================================================

# ALB name
output "alb_name" {
  value = aws_lb.web_alb.name
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "alb_dns_name" {
  value = aws_lb.web_alb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.web_alb.zone_id
}

output "web_tg_blue_arn" {
  value = aws_lb_target_group.web_tg_blue.arn
}

output "web_tg_green_arn" {
  value = aws_lb_target_group.web_tg_green.arn
}

output "https_listener_arn" {
  value = aws_lb_listener.https.arn
}

output "alb_logs_bucket" {
  value = aws_s3_bucket.alb_logs.bucket
}

output "web_alb_arn" {
  value = aws_lb.web_alb.arn
}

output "alb_logs_prefix" {
  value = var.alb_logs_prefix
}
