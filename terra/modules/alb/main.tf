# =======================================================
# ALB MODULE - PYFLEET (CloudFront-ready)
# =======================================================
# - Security Group (CloudFront-aware)
# - Application Load Balancer
# - Target Groups (Blue / Green)
# - HTTPS Listener + HTTP → HTTPS Redirect
# - ALB Logging
# =======================================================

# -------------------------
# CloudFront Prefix List (AWS-managed)
# -------------------------
data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

# -------------------------
# ALB SECURITY GROUP
# -------------------------
resource "aws_security_group" "alb_sg" {
  name        = var.alb_sg_name
  description = "Allow HTTP and HTTPS from CloudFront only"
  vpc_id      = var.vpc_id

  # Allow HTTPS from CloudFront 
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.cloudfront.id]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.my_ip
  }


  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = var.alb_sg_name })
}

# -------------------------
# ALB LOGGING BUCKET
# -------------------------
resource "aws_s3_bucket" "alb_logs" {
  bucket = var.alb_logs_bucket
  tags   = merge(var.tags, { "Purpose" = "ALB access logs" })
}

# -------------------------
# APPLICATION LOAD BALANCER
# -------------------------
resource "aws_lb" "web_alb" {
  name               = var.alb_name
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnets

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    prefix  = var.alb_logs_prefix
    enabled = true
  }

  tags = var.tags
}

# -------------------------
# TARGET GROUPS (BLUE/GREEN)
# -------------------------
resource "aws_lb_target_group" "web_tg_blue" {
  name     = "${var.tg_name}-blue"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
  }

  tags = var.tags
}

resource "aws_lb_target_group" "web_tg_green" {
  name     = "${var.tg_name}-green"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
  }

  tags = var.tags
}

# -------------------------
# HTTPS LISTENER
# -------------------------
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = var.active_color == "blue" ? aws_lb_target_group.web_tg_blue.arn : aws_lb_target_group.web_tg_green.arn
  }
}

