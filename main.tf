locals {
  full_name = "${var.name_prefix}-${var.environment}-${var.name_suffix}"
}

resource "aws_lb" "this" {
  name            = local.full_name
  subnets         = var.subnets
  security_groups = var.security_groups
}

resource "aws_lb_target_group" "this" {
  name        = local.full_name # You need to change the name of the target group to create new target groups
  port        = var.port
  protocol    = var.protocol
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    protocol = var.protocol
    enabled  = true
    interval = var.interval
    timeout  = var.timeout
    path     = var.health_check_path
  }

  lifecycle {
    create_before_destroy = true
  }

}

# Redirecting all traffic from LB to target group

resource "aws_lb_listener" "this_listener_http_redirect" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "this_listener_main_ssl" {
  count = var.has_cert ? 1 : 0 # Hack to make this conditional

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  depends_on = [aws_lb.this]
}

resource "aws_lb_listener" "this_listener_main_no_ssl" {
  count = var.has_cert ? 0 : 1 # Hack to make this conditional

  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  depends_on = [aws_lb.this]
}

output "alb_url" {
  value = aws_lb.this.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}
