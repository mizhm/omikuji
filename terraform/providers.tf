provider "aws" {
  alias      = "tokyo"
  region     = var.aws_region_tokyo
  access_key = var.aws_access_key
  secret_key = var.aws_secret_access_key

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      Region      = var.aws_region_tokyo
      Purpose     = "Active"
      ManagedBy   = "Terraform"
    }
  }
}

provider "aws" {
  alias      = "osaka"
  region     = var.aws_region_osaka
  access_key = var.aws_access_key
  secret_key = var.aws_secret_access_key

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      Region      = var.aws_region_osaka
      Purpose     = "Passive"
      ManagedBy   = "Terraform"
    }
  }
}

# Default provider for global resources if needed
provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_access_key
}
