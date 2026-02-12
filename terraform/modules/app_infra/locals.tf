locals {
  name_prefix = "${var.project_name}-${var.environment}-${var.region_name}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "minhnt146"
    Purpose     = "demo"
  }
}
