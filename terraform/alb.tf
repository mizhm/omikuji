resource "aws_lb" "public_alb" {
  name               = "${local.name_prefix}-public-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_public.id]
  subnets            = [for s in aws_subnet.public : s.id]

  tags = {
    Name = "${local.name_prefix}-public-alb"
  }
}

resource "aws_lb_listener" "public_http" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_instance.arn
  }
}

resource "aws_lb_target_group" "public_instance" {
  name     = "${local.name_prefix}-public-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/api/health"
    port = "3000"
  }

  tags = {
    Name = "${local.name_prefix}-public-tg"
  }
}

resource "aws_lb" "private_alb" {
  name               = "${local.name_prefix}-private-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_private.id]
  subnets            = [for s in aws_subnet.private : s.id]

  tags = {
    Name = "${local.name_prefix}-private-alb"
  }
}

resource "aws_lb_listener" "private_http" {
  load_balancer_arn = aws_lb.private_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private_instance.arn
  }
}

resource "aws_lb_target_group" "private_instance" {
  name     = "${local.name_prefix}-private-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path = "/health"
    port = "8080"
  }

  tags = {
    Name = "${local.name_prefix}-private-tg"
  }
}
