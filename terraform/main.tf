locals {
  public_subnets  = { for k, v in aws_subnet.subnet : k => v if startswith(k, "public") }
  private_subnets = { for k, v in aws_subnet.subnet : k => v if startswith(k, "private") }
}

data "aws_availability_zones" "available" {
  state = "available"
}

//VPC
resource "aws_vpc" "main" {
  cidr_block = "10.1.0.0/20"

  tags = {
    Name = "minhnt146-vpc-terraform"
  }
}

//IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "minhnt146-vpc-terraform-igw"
  }
}

//NATGW
resource "aws_nat_gateway" "natgw" {
  vpc_id            = aws_vpc.main.id
  availability_mode = "regional"

  tags = {
    Name = "minhnt146-vpc-terraform-natgw"
  }
}

//S3 vpc endpoint
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.us-east-1.s3"
}

//Route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "minhnt146-vpc-terraform-rtb-public"
  }
}

resource "aws_route_table" "private" {
  for_each = local.private_subnets
  vpc_id   = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw.id
  }

  tags = {
    Name = "minhnt146-vpc-terraform-rtb-${each.key}"
  }
}

//Subnet
resource "aws_subnet" "subnet" {
  for_each = {
    "public_1"  = { az = "us-east-1a", cidr = "10.1.1.0/24" }
    "public_2"  = { az = "us-east-1b", cidr = "10.1.2.0/24" }
    "private_1" = { az = "us-east-1a", cidr = "10.1.3.0/24" }
    "private_2" = { az = "us-east-1b", cidr = "10.1.4.0/24" }
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = startswith(each.key, "public")

  tags = {
    Name = "minhnt146-vpc-terraform-subnet-${each.key}"
  }
}

resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}

resource "aws_vpc_endpoint_route_table_association" "private" {
  for_each = local.private_subnets

  vpc_endpoint_id = aws_vpc_endpoint.s3.id
  route_table_id  = aws_route_table.private[each.key].id
}

//ELB
resource "aws_lb" "public_alb" {
  name               = "external-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_alb_sg.id]
  subnets            = [for k, v in local.public_subnets : v.id]
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "443"
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_instance_tg.arn
  }
}

resource "aws_lb_listener" "private_http" {
  load_balancer_arn = aws_lb.private_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private_instance_tg.arn
  }
}

resource "aws_lb" "private_alb" {
  name               = "internal-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.private_alb_sg.id]
  subnets            = [for k, v in local.private_subnets : v.id]
}

//Target group
resource "aws_lb_target_group" "public_instance_tg" {
  name     = "public-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/"
    port = "3000"
  }
}

resource "aws_lb_target_group" "private_instance_tg" {
  name     = "private-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/health"
    port = "8080"
  }
}


//SG
resource "aws_security_group" "public_alb_sg" {
  name        = "minhnt146-public-alb-sg"
  description = "Security group for public alb"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "minhnt146-public-alb-sg"
  }
}

resource "aws_security_group" "private_alb_sg" {
  name        = "minhnt146-private-alb-sg"
  description = "Security group for internal alb"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "minhnt146-private-alb-sg"
  }
}

resource "aws_security_group" "minhnt146_bastion_host" {
  name        = "minhnt146-bastion-host-sg"
  description = "Security group for bastion host in public subnet"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "minhnt146-bastion-host-sg"
  }
}

resource "aws_security_group" "minhnt146_public_sg" {
  name        = "minhnt146-public-sg"
  description = "Security group for public instance in public subnet"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "minhnt146-public-sg"
  }
}

resource "aws_security_group" "minhnt146_private_sg" {
  name        = "minhnt146-private-sg"
  description = "Allow ping from private instance"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "minhnt146-private-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_to_public_alb" {
  security_group_id = aws_security_group.public_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_to_public_alb" {
  security_group_id = aws_security_group.public_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}


resource "aws_vpc_security_group_egress_rule" "public_alb_to_targets" {
  security_group_id            = aws_security_group.public_alb_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 3000
  to_port                      = 3000
  referenced_security_group_id = aws_security_group.minhnt146_public_sg.id
}

resource "aws_vpc_security_group_egress_rule" "public_sg_internet_https" {
  security_group_id = aws_security_group.minhnt146_public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "Allow HTTPS outbound (repo download)"
}

resource "aws_vpc_security_group_egress_rule" "public_sg_internet_http" {
  security_group_id = aws_security_group.minhnt146_public_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  description       = "Allow HTTP outbound (backend access)"
}

resource "aws_vpc_security_group_egress_rule" "private_alb_to_targets" {
  security_group_id            = aws_security_group.private_alb_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
  referenced_security_group_id = aws_security_group.minhnt146_private_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_to_private_alb" {
  security_group_id            = aws_security_group.private_alb_sg.id
  referenced_security_group_id = aws_security_group.minhnt146_public_sg.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_to_bastion_host" {
  security_group_id = aws_security_group.minhnt146_bastion_host.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_ssh_to_private_sg" {
  security_group_id            = aws_security_group.minhnt146_bastion_host.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.minhnt146_private_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_public_alb" {
  security_group_id            = aws_security_group.minhnt146_public_sg.id
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.public_alb_sg.id
  from_port                    = 3000
  to_port                      = 3000
}

resource "aws_vpc_security_group_ingress_rule" "allow_bastion_ssh" {
  security_group_id            = aws_security_group.minhnt146_private_sg.id
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.minhnt146_bastion_host.id
  from_port                    = 22
  to_port                      = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_private_alb" {
  security_group_id            = aws_security_group.minhnt146_private_sg.id
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.private_alb_sg.id
  from_port                    = 8080
  to_port                      = 8080
}

resource "aws_vpc_security_group_egress_rule" "allow_all_icmp" {
  security_group_id = aws_security_group.minhnt146_private_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
}

resource "aws_vpc_security_group_egress_rule" "allow_ssm_https" {
  security_group_id = aws_security_group.minhnt146_private_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "Allow SSM Agent to reach Systems Manager endpoint"
}

resource "aws_launch_template" "bastion_host_lt" {
  name     = "bastion-host-lt"
  image_id = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  iam_instance_profile {
    name = "AmazonSSMRoleForInstancesQuickSetup"
  }
  instance_type          = "t2.nano"
  vpc_security_group_ids = [aws_security_group.minhnt146_bastion_host.id]
  key_name               = "minhnt146-keypair"
  update_default_version = true
}

resource "aws_launch_template" "public_instance_lt" {
  name     = "public-instance-lt"
  image_id = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  iam_instance_profile {
    name = "AmazonSSMRoleForInstancesQuickSetup"
  }
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.minhnt146_public_sg.id]
  key_name               = "minhnt146-keypair"
  update_default_version = true
  user_data = base64encode(templatefile("${path.module}/scripts/frontend.sh", {
    api_url = "http://${aws_lb.private_alb.dns_name}"
  }))
}

resource "aws_launch_template" "private_instance_lt" {
  name     = "private-instance-lt"
  image_id = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  iam_instance_profile {
    name = "AmazonSSMRoleForInstancesQuickSetup"
  }
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.minhnt146_private_sg.id]
  key_name               = "minhnt146-keypair"
  update_default_version = true
  user_data              = filebase64("${path.module}/scripts/api.sh")
}

//ASG
resource "aws_autoscaling_group" "bastion_host" {
  vpc_zone_identifier = [for k, v in local.public_subnets : v.id]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.bastion_host_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "bastion_host_scale_policy" {
  autoscaling_group_name = aws_autoscaling_group.bastion_host.name
  name                   = "bastion-host-scale-policy"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 40
  }
}

resource "aws_autoscaling_group" "public_instance_asg" {
  vpc_zone_identifier = [for k, v in local.public_subnets : v.id]
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.public_instance_tg.arn]

  launch_template {
    id      = aws_launch_template.public_instance_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "public_instance_asg_scale_policy" {
  autoscaling_group_name = aws_autoscaling_group.public_instance_asg.name
  name                   = "public-instance-scale-policy"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 40
  }
}

resource "aws_autoscaling_group" "private_instance" {
  vpc_zone_identifier = [for k, v in local.private_subnets : v.id]
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.private_instance_tg.arn]

  launch_template {
    id      = aws_launch_template.private_instance_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "private_instance_scale_policy" {
  autoscaling_group_name = aws_autoscaling_group.private_instance.name
  name                   = "private-instance-scale-policy"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 40
  }
}
