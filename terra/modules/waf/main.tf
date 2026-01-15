# =======================================================
# WAF MODULE v4 - PYFLEET
# - Supports ALB (REGIONAL) & CloudFront (CLOUDFRONT)
# - Rate limiting
# - Admin IP allowlist
# - Country blocking
# - Logging to Clouwatch
# =======================================================

resource "aws_wafv2_web_acl" "this" {
  name  = var.name
  scope = var.scope

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
    metric_name                = replace(var.name, "_", "-")
  }

  tags = var.tags

  # Login rate limit
  rule {
    name     = "LoginRateLimit"
    priority = 100
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = var.login_rate_limit
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "login-rate-limit"
    }
  }

  # API rate limit
  rule {
    name     = "ApiRateLimit"
    priority = 200
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit              = var.api_rate_limit
        aggregate_key_type = "IP"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "api-rate-limit"
    }
  }

  # Admin IP allowlist
  dynamic "rule" {
    for_each = var.admin_ip_allowlist
    content {
      name     = "AllowAdminIP-${replace(replace(rule.value, ".", "-"), "/", "_")}"
      priority = 500 + index(var.admin_ip_allowlist, rule.value)
      action {
        allow {}
      }
      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.admin[0].arn
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = true
        metric_name                = "allow-admin-${replace(replace(rule.value, ".", "-"), "/", "_")}"
      }
    }
  }

  # Country blocking
  dynamic "rule" {
    for_each = var.blocked_countries
    content {
      name     = "BlockCountry-${rule.value}"
      priority = 1000 + index(var.blocked_countries, rule.value)
      action {
        block {}
      }
      statement {
        geo_match_statement {
          country_codes = [rule.value]
        }
      }
      visibility_config {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = true
        metric_name                = "block-country-${lower(rule.value)}"
      }
    }
  }
}

# Admin IP Set
resource "aws_wafv2_ip_set" "admin" {
  count              = length(var.admin_ip_allowlist) > 0 ? 1 : 0
  name               = "${var.name}-admin-ips"
  scope              = var.scope
  ip_address_version = "IPV4"
  addresses          = var.admin_ip_allowlist
  tags               = var.tags
}

# -------------------------
# CloudWatch logging for WAF
# -------------------------
resource "aws_cloudwatch_log_group" "waf_logs" {
  count             = var.enable_logging ? 1 : 0
  name              = "/waf/${var.name}"
  retention_in_days = 90
  tags              = merge(var.tags, { Purpose = "WAF Logs" })
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count = var.enable_logging ? 1 : 0

  resource_arn            = aws_wafv2_web_acl.this.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs[0].arn]

  redacted_fields {
    single_header {
      name = "Authorization"
    }
  }
}
