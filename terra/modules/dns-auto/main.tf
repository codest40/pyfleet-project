# -------------------------
# DuckDNS updater
# -------------------------
# NOTE:
# DuckDNS does not have an official Terraform provider.
# We use a null_resource with local-exec for learning purposes.
# This runs on local machine, not inside AWS.
# -------------------------

# -------------------------
# Locals
# -------------------------
locals {
  dns_target_name = coalesce(var.cloudfront_domain, var.alb_dns_name)
  dns_zone_id     = coalesce(var.cloudfront_zone, var.alb_zone_id)
}

# -------------------------
# DuckDNS updater
# -------------------------
resource "null_resource" "duckdns_update" {
  triggers = {
    dns_target = local.dns_target_name
  }

  provisioner "local-exec" {
    command = <<EOT
curl -s "https://www.duckdns.org/update?domains=${var.duckdns_domain}&token=${var.duckdns_token}&ip="
EOT
  }
}

# -------------------------
# Route53 record
# -------------------------
resource "aws_route53_record" "dns_record" {
  zone_id = local.dns_zone_id
  name    = var.duckdns_domain
  type    = "A"

  alias {
    name                   = local.dns_target_name
    zone_id                = local.dns_zone_id
    evaluate_target_health = true
  }
}
