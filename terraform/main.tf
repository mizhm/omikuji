# Main configuration file
# This file can be used for global data sources or resources that don't fit into other categories.

data "aws_availability_zones" "available" {
  state = "available"
}
