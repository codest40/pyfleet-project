# =========================
# GLOBAL CONTEXT
# =========================

variable "project_name" {
  description = "Project name for alarm naming and tagging"
  type        = string
  default     = "pyfleet"
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

variable "tags" {
  description = "Common tags applied to all monitoring resources"
  type        = map(string)
}

# =========================
# ALB INPUTS
# =========================

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
}

# =========================
# TARGET GROUP INPUTS (BLUE/GREEN)
# =========================

variable "target_groups" {
  description = "Map of target groups to monitor (blue/green)"
  type = map(object({
    arn  = string
    name = string
  }))
}

# =========================
# ASG INPUTS
# =========================

variable "asg_name" {
  description = "Name of the active Auto Scaling Group"
  type        = string
}

# =========================
# ALERTING
# =========================

variable "enable_alerts" {
  description = "Whether to enable CloudWatch alarms"
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
  default     = null
}

variable "alert_email" {
  description = "Email address to receive monitoring alerts"
  type        = string
}

variable "alb_5xx_threshold" {
  description = "ALB 5XX error threshold per minute"
  type        = number
  default     = 5
}

variable "unhealthy_host_threshold" {
  description = "Number of unhealthy targets that triggers alarm"
  type        = number
  default     = 1
}

# =========================
# DASHBOARD
# =========================

variable "dashboard_name" {
  description = "CloudWatch dashboard name"
  type        = string
}
