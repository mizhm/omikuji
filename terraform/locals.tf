locals {
  name_prefix = "minhnt146-demo"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "minhnt146"
    Purpose     = "demo"
  }
}
