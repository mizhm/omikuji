
resource "aws_lb_listener_rule" "health_check" {
  listener_arn = aws_lb_listener.public_http.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_instance.arn
  }

  condition {
    path_pattern {
      values = ["/api/health"]
    }
  }
}
