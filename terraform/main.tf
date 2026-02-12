data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# --- Module: Tokyo (Active) ---
module "tokyo_app" {
  source = "./modules/app_infra"
  providers = {
    aws = aws.tokyo
  }

  region_name          = "tokyo"
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  allowed_ssh_cidr     = var.allowed_ssh_cidr
  instance_type        = var.instance_type
  key_name             = "demo" # Hardcoded key name or verify existing key in both regions? Key pairs are regional!
  # Note: The key pair 'demo' must exist in BOTH ap-northeast-1 and ap-northeast-3.
}

# --- Module: Osaka (Passive) ---
module "osaka_app" {
  source = "./modules/app_infra"
  providers = {
    aws = aws.osaka
  }

  region_name          = "osaka"
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = "10.1.0.0/16"
  public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
  private_subnet_cidrs = ["10.1.10.0/24", "10.1.11.0/24"]
  allowed_ssh_cidr     = var.allowed_ssh_cidr
  instance_type        = var.instance_type
  key_name             = "demo" # Key pair 'demo' must exist in Osaka too.
}

# --- Route 53 Health Check (for Active Region) ---
resource "aws_route53_health_check" "tokyo_health" {
  fqdn              = module.tokyo_app.public_alb_dns_name
  port              = 80
  type              = "HTTP"
  resource_path     = "/api/health" # Checks the health of the application
  failure_threshold = "3"
  request_interval  = "30"

  tags = {
    Name = "tokyo-health-check"
  }
}

# --- Route 53 Failover Records ---

# Primary (Active) - Points to Tokyo
resource "aws_route53_record" "www_primary" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.subdomain}.${var.domain_name}"
  type    = "A"
  
  failover_routing_policy {
    type = "PRIMARY"
  }
  
  set_identifier  = "tokyo-primary"
  health_check_id = aws_route53_health_check.tokyo_health.id

  alias {
    name                   = module.tokyo_app.public_alb_dns_name
    zone_id                = module.tokyo_app.public_alb_zone_id
    evaluate_target_health = true
  }
}

# Secondary (Passive) - Points to Osaka
resource "aws_route53_record" "www_secondary" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${var.subdomain}.${var.domain_name}"
  type    = "A"
  
  failover_routing_policy {
    type = "SECONDARY"
  }
  
  set_identifier = "osaka-secondary"
  
  alias {
    name                   = module.osaka_app.public_alb_dns_name
    zone_id                = module.osaka_app.public_alb_zone_id
    evaluate_target_health = true
  }
}
