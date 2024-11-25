// Load Balancer Target Group 생성
resource "aws_lb_target_group" "this" {
  name               = var.target_group_name
  port               = var.target_group_port
  protocol           = var.target_group_protocol
  vpc_id             = var.vpc_id
  target_type        = var.target_type
  deregistration_delay = var.deregistration_delay

  health_check {
    path                = var.health_check_path
    protocol            = var.health_check_protocol
    matcher             = var.health_check_matcher
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }
}

// Load Balancer 생성
resource "aws_lb" "this" {
  name               = var.lb_name
  internal           = var.lb_internal
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnets

  enable_deletion_protection = var.enable_deletion_protection
}

// Load Balancer Listener (HTTP → HTTPS Redirect) 생성
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.http_listener_port
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol   = "HTTPS"
      port       = var.https_listener_port
      status_code = "HTTP_301"
    }
  }
}

// Load Balancer Listener (HTTPS) 생성
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.https_listener_port
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}