# =========================
# TARGET GROUP HEALTH ALARMS
# =========================
# Triggers if ANY target becomes unhealthy
resource "aws_cloudwatch_metric_alarm" "tg_unhealthy_hosts" {
  for_each = var.enable_alerts ? var.target_groups : {}

  alarm_name = "${var.project_name}-${var.environment}-${each.key}-tg-unhealthy"
  alarm_description = "Unhealthy targets detected in ${each.key} target group"

  namespace   = "AWS/ApplicationELB"
  metric_name = "UnHealthyHostCount"
  statistic   = "Average"
  period      = 60
  evaluation_periods = 2
  threshold   = 0
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    TargetGroup = each.value.name
    LoadBalancer = var.alb_name
  }

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
  ok_actions    = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  tags = var.tags
}


# =========================
# ALB 5XX ERROR RATE
# =========================
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  count = var.enable_alerts ? 1 : 0

  alarm_name        = "${var.project_name}-${var.environment}-alb-5xx"
  alarm_description = "ALB is returning 5XX errors"

  namespace   = "AWS/ApplicationELB"
  metric_name = "HTTPCode_ELB_5XX_Count"
  statistic   = "Sum"
  period      = 60
  evaluation_periods = 2
  threshold   = 5
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    LoadBalancer = var.alb_name
  }

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
  ok_actions    = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  tags = var.tags
}


# =========================
# ALB LATENCY (P95)
# =========================
resource "aws_cloudwatch_metric_alarm" "alb_latency_p95" {
  count = var.enable_alerts ? 1 : 0

  alarm_name        = "${var.project_name}-${var.environment}-alb-latency"
  alarm_description = "High ALB response latency (p95)"

  namespace   = "AWS/ApplicationELB"
  metric_name = "TargetResponseTime"
  extended_statistic   = "p95"
  period      = 60
  evaluation_periods = 3
  threshold   = 2
  comparison_operator = "GreaterThanThreshold"

  dimensions = {
    LoadBalancer = var.alb_name
  }

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
  ok_actions    = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  tags = var.tags
}


# =========================
# ASG CAPACITY HEALTH
# =========================
resource "aws_cloudwatch_metric_alarm" "asg_insufficient_capacity" {
  count = var.enable_alerts ? 1 : 0

  alarm_name        = "${var.project_name}-${var.environment}-asg-capacity"
  alarm_description = "ASG does not have enough InService instances"

  namespace   = "AWS/AutoScaling"
  metric_name = "GroupInServiceInstances"
  statistic   = "Minimum"
  period      = 60
  evaluation_periods = 2
  threshold   = 1
  comparison_operator = "LessThanThreshold"

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
  ok_actions    = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  tags = var.tags
}

# =========================
# SNS ALERT TOPIV
# =========================
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"

  tags = var.tags
}

# Email subscription for alerts
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

#=========================
# ALB 5XX ERROR ALARM
#=========================
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "${var.project_name}-alb-5xx"
  alarm_description   = "ALB is returning 5XX errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Sum"
  threshold           = var.alb_5xx_threshold

  dimensions = {
    LoadBalancer = var.alb_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = var.tags
}

#=========================
# TARGET GROUP UNHEALTHY HOSTS
#=========================
resource "aws_cloudwatch_metric_alarm" "tg_unhealthy" {
  for_each = var.target_groups

  alarm_name          = "${var.project_name}-${each.key}-tg-unhealthy"
  alarm_description   = "Unhealthy targets detected in ${each.key} target group"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = var.unhealthy_host_threshold

  dimensions = {
    TargetGroup  = each.value.name
    LoadBalancer = var.alb_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = var.tags
}

#=========================
# ASG CAPACITY DROP
#=========================
resource "aws_cloudwatch_metric_alarm" "asg_capacity" {
  alarm_name          = "${var.project_name}-asg-capacity-drop"
  alarm_description   = "ASG InService capacity dropped"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "GroupInServiceInstances"
  namespace           = "AWS/AutoScaling"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]

  tags = var.tags
}


# =========================
# CLOUDWATCH DASHBOARD
# =========================
resource "aws_cloudwatch_dashboard" "service_dashboard" {
  dashboard_name = var.dashboard_name

  dashboard_body = jsonencode({
    widgets = [

      # =========================
      # ALB REQUEST COUNT
      # =========================
      {
        type = "metric"
        x = 0
        y = 0
        width = 12
        height = 6

        properties = {
          title  = "ALB Request Count"
          region = "us-east-1"
          metrics = [
            [
              "AWS/ApplicationELB",
              "RequestCount",
              "LoadBalancer",
              var.alb_name
            ]
          ]
          period = 60
          stat   = "Sum"
        }
      },

      # =========================
      # ALB 5XX ERRORS
      # =========================
      {
        type = "metric"
        x = 12
        y = 0
        width = 12
        height = 6

        properties = {
          title  = "ALB 5XX Errors"
          region = "us-east-1"
          metrics = [
            [
              "AWS/ApplicationELB",
              "HTTPCode_ELB_5XX_Count",
              "LoadBalancer",
              var.alb_name
            ]
          ]
          period = 60
          stat   = "Sum"
        }
      },

      # =========================
      # ALB LATENCY (P95)
      # =========================
      {
        type = "metric"
        x = 0
        y = 6
        width = 12
        height = 6

        properties = {
          title  = "ALB Target Response Time (p95)"
          region = "us-east-1"
          metrics = [
            [
              "AWS/ApplicationELB",
              "TargetResponseTime",
              "LoadBalancer",
              var.alb_name
            ]
          ]
          period = 60
          stat   = "p95"
        }
      },

      # =========================
      # TARGET GROUP HEALTH
      # =========================
      {
        type = "metric"
        x = 12
        y = 6
        width = 12
        height = 6

        properties = {
          title  = "Target Group Healthy / Unhealthy Hosts"
          region = "us-east-1"
          metrics = flatten([
            for tg_key, tg in var.target_groups : [
              [
                "AWS/ApplicationELB",
                "HealthyHostCount",
                "TargetGroup",
                tg.name,
                "LoadBalancer",
                var.alb_name
              ],
              [
                "AWS/ApplicationELB",
                "UnHealthyHostCount",
                "TargetGroup",
                tg.name,
                "LoadBalancer",
                var.alb_name
              ]
            ]
          ])
          period = 60
          stat   = "Average"
        }
      },

      # =========================
      # ASG CAPACITY
      # =========================
      {
        type = "metric"
        x = 0
        y = 12
        width = 24
        height = 6

        properties = {
          title  = "ASG InService Instances"
          region = "us-east-1"
          metrics = [
            [
              "AWS/AutoScaling",
              "GroupInServiceInstances",
              "AutoScalingGroupName",
              var.asg_name
            ]
          ]
          period = 60
          stat   = "Minimum"
        }
      }
    ]
  })
}
