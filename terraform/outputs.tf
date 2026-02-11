output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_alb_dns_name" {
  description = "DNS name of the public ALB"
  value       = aws_lb.public_alb.dns_name
}

output "private_alb_dns_name" {
  description = "DNS name of the private ALB"
  value       = aws_lb.private_alb.dns_name
}

output "bastion_public_ip" {
  description = "Public IP (or DNS) of the Bastion autoscaling group"
  value       = aws_autoscaling_group.bastion_host.name
}
