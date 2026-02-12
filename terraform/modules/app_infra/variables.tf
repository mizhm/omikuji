variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "region_name" {
  description = "Region name for tagging (e.g. tokyo, osaka)"
  type        = string
}

variable "project_name" {
  description = "Project name prefix for resources"
  type        = string
  default     = "omikuji"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/20"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into bastion host"
  type        = string
  default     = "0.0.0.0/0"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "demo"
}

variable "domain_name" {
  description = "Domain name for the application (e.g. example.com)"
  type        = string
}

variable "subdomain" {
  description = "Subdomain for the application (e.g. www)"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 Hosted Zone ID for DNS validation"
  type        = string
}


