variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
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

variable "public_subnets" {
  description = "Map of public subnets with AZ and CIDR"
  type = map(object({
    az   = string
    cidr = string
  }))
  default = {
    "public-1" = { az = "us-east-1a", cidr = "10.1.1.0/24" }
    "public-2" = { az = "us-east-1b", cidr = "10.1.2.0/24" }
  }
}

variable "private_subnets" {
  description = "Map of private subnets with AZ and CIDR"
  type = map(object({
    az   = string
    cidr = string
  }))
  default = {
    "private-1" = { az = "us-east-1a", cidr = "10.1.3.0/24" }
    "private-2" = { az = "us-east-1b", cidr = "10.1.4.0/24" }
  }
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

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key"
  type        = string
  sensitive   = true
}
