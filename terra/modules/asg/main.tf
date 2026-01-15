# =======================================================
# ASG Module v2 - pyfleet
# =======================================================
# - Launch Template with IAM, SGs, and ECR Docker setup
# - Auto Scaling Group in private subnets
# - Attach to ALB target group
# - CPU + Memory based scaling
# - Blue/Green deployment support
# =======================================================

# -------------------------
# LAUNCH TEMPLATE
# -------------------------
resource "aws_launch_template" "web_lt" {
  name_prefix   = "web-asg-v2-"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name

  # -------------------------
  # IAM Instance Profile
  # -------------------------
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  # -------------------------
  # Security Groups
  # -------------------------
  vpc_security_group_ids = var.security_group_ids

  # -------------------------
  # User Data: Docker + ECR + CloudWatch Agent
  # -------------------------
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -e

    yum update -y
    amazon-linux-extras install docker -y
    systemctl enable docker
    systemctl start docker

    # Install CloudWatch Agent
    yum install -y amazon-cloudwatch-agent

    # CloudWatch Agent config (Memory metrics)
    cat <<CONFIG > /opt/aws/amazon-cloudwatch-agent/bin/config.json
    {
      "metrics": {
        "namespace": "Pyfleet/EC2",
        "metrics_collected": {
          "mem": {
            "measurement": ["mem_used_percent"],
            "metrics_collection_interval": 60
          }
        }
      }
    }
    CONFIG

    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
      -a fetch-config -m ec2 \
      -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s

    # Login to ECR and pull image
    aws ecr get-login-password --region ${var.region} \
      | docker login --username AWS --password-stdin ${var.ecr_repo_url}

    docker pull ${var.ecr_repo_url}:latest

    # Systemd service
    cat <<SERVICE > /etc/systemd/system/pyfleet.service
    [Unit]
    Description=pyfleet Docker Container
    After=docker.service
    Requires=docker.service

    [Service]
    Restart=always
    ExecStart=/usr/bin/docker run --rm --name pyfleet -p 80:80 ${var.ecr_repo_url}:latest
    ExecStop=/usr/bin/docker stop pyfleet

    [Install]
    WantedBy=multi-user.target
    SERVICE

    systemctl daemon-reload
    systemctl enable pyfleet
    systemctl start pyfleet
  EOF
  )
}

# -------------------------
# Security Groups
# -------------------------
resource "aws_security_group" "asg_sg" {
  name   = "${var.asg_name}-${var.name_suffix}-sg"
  vpc_id = var.vpc_id

  ingress {
    description     = "Allow SSH from bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
  }

  # Outbound to DB
  egress {
    description     = "Allow outbound Postgres to DB"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.db_security_group_id != "" ? [var.db_security_group_id] : []
  }

  # Allow all other outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------
# AUTO SCALING GROUP
# -------------------------
resource "aws_autoscaling_group" "web_asg" {
  name_prefix = "${var.asg_name}-${var.name_suffix}-"

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  vpc_zone_identifier = var.subnet_ids

  health_check_type         = "ELB"
  health_check_grace_period = 60

  target_group_arns = [var.alb_target_group_arn]

  force_delete = true

  tag {
    key                 = "Name"
    value               = var.instance_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "pyfleet"
    propagate_at_launch = true
  }

  tag {
    key                 = "Env"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = "DevOps"
    propagate_at_launch = true
  }
}

# -------------------------
# SCALING POLICIES
# -------------------------
resource "aws_autoscaling_policy" "cpu_scale_up" {
  name                   = "${var.asg_name}-cpu-scale-up"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.cpu_scale_up_adjustment
  cooldown               = 300
}

resource "aws_autoscaling_policy" "cpu_scale_down" {
  name                   = "${var.asg_name}-cpu-scale-down"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -var.cpu_scale_down_adjustment
  cooldown               = 300
}

resource "aws_autoscaling_policy" "mem_scale_up" {
  name                   = "${var.asg_name}-mem-scale-up"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = var.mem_scale_up_adjustment
  cooldown               = 300
}

resource "aws_autoscaling_policy" "mem_scale_down" {
  name                   = "${var.asg_name}-mem-scale-down"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -var.mem_scale_down_adjustment
  cooldown               = 300
}

# -------------------------
# CPU CLOUDWATCH ALARMS
# -------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.asg_name}-${var.name_suffix}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.cpu_high_threshold

  alarm_actions = [aws_autoscaling_policy.cpu_scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "${var.asg_name}-${var.name_suffix}-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.cpu_low_threshold

  alarm_actions = [aws_autoscaling_policy.cpu_scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }
}

# -------------------------
# MEMORY CLOUDWATCH ALARMS
# -------------------------
resource "aws_cloudwatch_metric_alarm" "mem_high" {
  alarm_name          = "${var.asg_name}-${var.name_suffix}-mem-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "Pyfleet/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.mem_high_threshold

  alarm_actions = [aws_autoscaling_policy.mem_scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "mem_low" {
  alarm_name          = "${var.asg_name}-${var.name_suffix}-mem-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "Pyfleet/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.mem_low_threshold

  alarm_actions = [aws_autoscaling_policy.mem_scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_asg.name
  }
}
