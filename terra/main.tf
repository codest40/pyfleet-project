# =======================================================
# ROOT MODULE
# =======================================================

provider "aws" {
  region = var.region
}

# -------------------------
# NETWORK MODULE
# -------------------------
module "network" {
  source   = "./modules/network"
  vpc_cidr = "10.0.0.0/16"

  azs = [
    {
      name           = "us-east-1a"
      public_bastion = "10.0.1.0/24"
      public_alb     = "10.0.2.0/24"
      private_app    = "10.0.11.0/24"
      private_db     = "10.0.21.0/24"
    },
    {
      name           = "us-east-1b"
      public_bastion = "10.0.3.0/24"
      public_alb     = "10.0.4.0/24"
      private_app    = "10.0.12.0/24"
      private_db     = "10.0.22.0/24"
    }
  ]

  enable_nat = true
  tags = {
    Project = var.project_name
    Env     = "dev"
    Owner   = "DevOps"
  }
}

# -------------------------
# ECR MODULE
# -------------------------
module "ecr" {
  source    = "./modules/ecr"
  repo_name = "pyfleet-ecr"
  region    = var.region
}

# -------------------------
# ACM MODULE
# -------------------------
module "acm" {
  source      = "./modules/acm"
  domain_name = var.domain_name
}

# -------------------------
# ALB MODULE 
# -------------------------
module "alb" {
  source          = "./modules/alb"
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_alb_subnets
  certificate_arn = module.acm.regional_cert_arn
  active_color    = var.active_color
  alb_logs_bucket = "pyfleet-alb-logs"
  tags            = var.tags
}

# -------------------------
# WAF MODULES
# -------------------------
# WAF Regional (ALB)
module "waf_alb" {
  source             = "./modules/waf"
  name               = "pyfleet-alb-waf"
  scope              = "REGIONAL"
  login_rate_limit   = 10
  api_rate_limit     = 200
  admin_ip_allowlist = ["203.0.113.10/32"]
  blocked_countries  = ["CN", "RU"]
  enable_logging     = false
  tags               = var.tags
}

# WAF Edge (CloudFront)
module "waf_cf" {
  source             = "./modules/waf"
  name               = "pyfleet-cf-waf"
  scope              = "CLOUDFRONT"
  login_rate_limit   = 10
  api_rate_limit     = 200
  admin_ip_allowlist = ["203.0.113.10/32"]
  blocked_countries  = ["CN", "RU"]
  enable_logging     = true
  tags               = var.tags
}

# -------------------------
# CLOUD FRONT MODULE
# -------------------------
module "cloudfront" {
  source          = "./modules/cloudfront"
  name            = "pyfleet-cdn"
  alb_dns_name    = module.alb.alb_dns_name
  certificate_arn = module.acm.cloudfront_cert_arn
  web_acl_arn     = module.waf_cf.web_acl_arn
  enable_logging  = true
  tags            = var.tags
}

# -------------------------
# ASG MODULES (Blue/Green)
# -------------------------
module "asg_blue" {
  source                    = "./modules/asg"
  name_suffix               = "blue"
  vpc_id                    = module.network.vpc_id
  region                    = var.region
  subnet_ids                = module.network.private_app_subnets
  ami                       = var.app_ami
  instance_type             = var.instance_type
  key_name                  = var.key
  security_group_ids        = [module.alb.alb_sg_id]
  bastion_sg_id             = module.bastion.bastion_sg_id
  alb_target_group_arn      = module.alb.web_tg_blue_arn
  ecr_repo_url              = module.ecr.repo_url
  iam_instance_profile_name = module.iam.instance_profile_name
  min_size                  = var.active_color == "blue" ? var.required_capacity : 0
  max_size                  = 2
  desired_capacity          = var.active_color == "blue" ? var.required_capacity : 0
  environment               = var.env
}

module "asg_green" {
  source                    = "./modules/asg"
  name_suffix               = "green"
  vpc_id                    = module.network.vpc_id
  region                    = var.region
  subnet_ids                = module.network.private_app_subnets
  ami                       = var.app_ami
  instance_type             = var.instance_type
  key_name                  = var.key
  security_group_ids        = [module.alb.alb_sg_id]
  bastion_sg_id             = module.bastion.bastion_sg_id
  alb_target_group_arn      = module.alb.web_tg_green_arn
  ecr_repo_url              = module.ecr.repo_url
  iam_instance_profile_name = module.iam.instance_profile_name
  min_size                  = var.active_color == "green" ? var.required_capacity : 0
  max_size                  = 2
  desired_capacity          = var.active_color == "green" ? var.required_capacity : 0
  environment               = var.env
}

# =========================
# BASTION MODUlE
# =========================
module "bastion" {
  source            = "./modules/bastion"
  ami               = var.bastion_ami
  instance_type     = var.bastion_instance_type
  key_name          = var.key
  public_subnet_ids = module.network.public_bastion_subnets
  vpc_id            = module.network.vpc_id
  my_ip_cidr        = var.my_ip_cidr
}

# =========================
# DB MODUlE
# =========================
module "db" {
  source             = "./modules/db"
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_db_subnets
  app_security_group_ids = [
    module.asg_blue.asg_sg_id,
    module.asg_green.asg_sg_id
  ]

  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_instance_class = "db.t3.medium"
  multi_az          = true
  replica_count     = 1
  tags              = { Env = "prod", Project = "pyfleet" }
}


# =========================
# DNS AUTOMATION MODULE
# =========================
module "dns_auto" {
  source            = "./modules/dns-auto"
  duckdns_token     = var.duckdns_token
  duckdns_domain    = var.duckdns_domain
  cloudfront_domain = module.cloudfront.distribution_domain_name
  cloudfront_zone   = module.cloudfront.distribution_id

  # ALB args optional
  alb_dns_name = module.alb.alb_dns_name
  alb_zone_id  = module.alb.alb_zone_id
}


# =========================
# IAM MODULE
# =========================
module "iam" {
  source = "./modules/iam"
}

# =========================
# MONITORING MODULE
# =========================
module "monitoring" {
  source         = "./modules/monitoring"
  project_name   = var.project_name
  environment    = "dev"
  dashboard_name = "pyfleet-sre-dashboard"
  alert_email    = var.my_email
  alb_name       = module.alb.alb_name
  asg_name       = var.active_color == "blue" ? module.asg_blue.asg_name : module.asg_green.asg_name
  target_groups = {
    blue  = { name = "pyfleet-tg-blue", arn = module.alb.web_tg_blue_arn }
    green = { name = "pyfleet-tg-green", arn = module.alb.web_tg_green_arn }
  }
  tags = {
    Project = var.project_name
    Env     = "dev"
    Owner   = "DevOps"
  }
}


# =========================
# COST MONITORING MODULE
# =========================
module "cost_monitoring" {
  source              = "./modules/monitoring-cost"
  project_name        = var.project_name
  daily_budget_amount = var.budget_amount
  alert_emails        = var.alert_emails
  tags = {
    Project   = var.project_name
    Env       = "dev"
    Owner     = "DevOps"
    ManagedBy = "Terraform"
  }
}

