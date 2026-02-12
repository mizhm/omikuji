# --- Bastion Host ---
resource "aws_launch_template" "bastion" {
  name_prefix   = "${local.name_prefix}-bastion-lt-"
  image_id      = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.bastion.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.name_prefix}-bastion"
    }
  }
}

resource "aws_autoscaling_group" "bastion_host" {
  name                = "${local.name_prefix}-bastion-asg"
  vpc_zone_identifier = [for s in aws_subnet.public : s.id]
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.bastion.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-bastion"
    propagate_at_launch = true
  }
}

# --- Public Instance (Frontend) ---
resource "aws_launch_template" "public_instance" {
  name_prefix   = "${local.name_prefix}-public-lt-"
  image_id      = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.public_instance.id]
  }

  user_data = base64encode(templatefile("${path.module}/scripts/frontend.sh", {
    api_url = "http://${aws_lb.private_alb.dns_name}"
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.name_prefix}-public-instance"
    }
  }
}

resource "aws_autoscaling_group" "public_instance" {
  name                = "${local.name_prefix}-public-asg"
  vpc_zone_identifier = [for s in aws_subnet.public : s.id]
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.public_instance.arn]

  launch_template {
    id      = aws_launch_template.public_instance.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-public-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "public_scale_policy" {
  autoscaling_group_name = aws_autoscaling_group.public_instance.name
  name                   = "${local.name_prefix}-public-scale-policy"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 40
  }
}

# --- Private Instance (Backend) ---
resource "aws_launch_template" "private_instance" {
  name_prefix   = "${local.name_prefix}-private-lt-"
  image_id      = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.private_instance.id]
  }

  user_data = base64encode(file("${path.module}/scripts/api.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${local.name_prefix}-private-instance"
    }
  }
}

resource "aws_autoscaling_group" "private_instance" {
  name                = "${local.name_prefix}-private-asg"
  vpc_zone_identifier = [for s in aws_subnet.private : s.id]
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  target_group_arns   = [aws_lb_target_group.private_instance.arn]

  launch_template {
    id      = aws_launch_template.private_instance.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-private-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "private_scale_policy" {
  autoscaling_group_name = aws_autoscaling_group.private_instance.name
  name                   = "${local.name_prefix}-private-scale-policy"
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 40
  }
}
