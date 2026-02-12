# --- Public ALB SG ---
resource "aws_security_group" "alb_public" {
  name        = "${local.name_prefix}-alb-public-sg"
  description = "Security group for public ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-alb-public-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_public_http" {
  security_group_id = aws_security_group.alb_public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "alb_public_https" {
  security_group_id = aws_security_group.alb_public.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "alb_public_to_targets" {
  security_group_id            = aws_security_group.alb_public.id
  referenced_security_group_id = aws_security_group.public_instance.id
  ip_protocol                  = "tcp"
  from_port                    = 3000
  to_port                      = 3000
}

# --- Private ALB SG ---
resource "aws_security_group" "alb_private" {
  name        = "${local.name_prefix}-alb-private-sg"
  description = "Security group for private ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-alb-private-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_private_from_public_instance" {
  security_group_id            = aws_security_group.alb_private.id
  referenced_security_group_id = aws_security_group.public_instance.id
  ip_protocol                  = "tcp"
  from_port                    = 80
  to_port                      = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_private_to_targets" {
  security_group_id            = aws_security_group.alb_private.id
  referenced_security_group_id = aws_security_group.private_instance.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
}

# --- Bastion Host SG ---
resource "aws_security_group" "bastion" {
  name        = "${local.name_prefix}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-bastion-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = var.allowed_ssh_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "bastion_to_private" {
  security_group_id            = aws_security_group.bastion.id
  referenced_security_group_id = aws_security_group.private_instance.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "bastion_http" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "bastion_https" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

# --- Public Instance SG ---
resource "aws_security_group" "public_instance" {
  name        = "${local.name_prefix}-public-instance-sg"
  description = "Security group for public instances"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-public-instance-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_instance_from_alb" {
  security_group_id            = aws_security_group.public_instance.id
  referenced_security_group_id = aws_security_group.alb_public.id
  ip_protocol                  = "tcp"
  from_port                    = 3000
  to_port                      = 3000
}

resource "aws_vpc_security_group_egress_rule" "public_instance_internet_https" {
  security_group_id = aws_security_group.public_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "Allow HTTPS outbound"
}

resource "aws_vpc_security_group_egress_rule" "public_instance_internet_http" {
  security_group_id = aws_security_group.public_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  description       = "Allow HTTP outbound"
}

# --- Private Instance SG ---
resource "aws_security_group" "private_instance" {
  name        = "${local.name_prefix}-private-instance-sg"
  description = "Security group for private instances"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-private-instance-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "private_instance_from_alb" {
  security_group_id            = aws_security_group.private_instance.id
  referenced_security_group_id = aws_security_group.alb_private.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
}

resource "aws_vpc_security_group_ingress_rule" "private_instance_ssh_bastion" {
  security_group_id            = aws_security_group.private_instance.id
  referenced_security_group_id = aws_security_group.bastion.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
}

resource "aws_vpc_security_group_egress_rule" "private_instance_internet_https" {
  security_group_id = aws_security_group.private_instance.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "Allow HTTPS outbound (e.g. S3 endpoint, SSM)"
}
