
resource "aws_wafv2_web_acl_association" "alb_assoc" {
  resource_arn = module.alb.web_alb_arn
  web_acl_arn  = module.waf_alb.web_acl_arn
}


