variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}
variable "aws_secret_access_key" {
  description = "AWS secret access key"
  type        = string
}
