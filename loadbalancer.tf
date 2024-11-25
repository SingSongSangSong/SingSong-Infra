// Load Balancer Target Group 생성
resource "aws_lb_target_group" "singsong_target_group" {
  name     = "singsong-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.singsong_vpc.id
  target_type = "ip"
  deregistration_delay = "5"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 150
    timeout             = 120
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

// Load Balancer 생성
resource "aws_lb" "singsong_load_balancer" {
  name               = "singsong-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.singsong_security_group.id]
  subnets            = [aws_subnet.singsong_public_subnet1.id, aws_subnet.singsong_public_subnet2.id]

  enable_deletion_protection = false
}

// Load Balancer Listener 생성
resource "aws_lb_listener" "singsong_listener" {
  load_balancer_arn = aws_lb.singsong_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol = "HTTPS"
      port     = "443"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "singsong_listener_https" {
  load_balancer_arn = aws_lb.singsong_load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.singsong_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.singsong_target_group.arn
  }
}

// Target Group for /milvus-db-monitoring
resource "aws_lb_target_group" "milvus_target_group" {
  name     = "milvus-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.singsong_vpc.id
  target_type = "ip"
  deregistration_delay = "5"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

// Listener Rule for /milvus-db-monitoring
resource "aws_lb_listener_rule" "milvus_db_monitoring_rule" {
  listener_arn = aws_lb_listener.singsong_listener_https.arn
  priority     = 100 # Adjust priority based on your existing rules

  condition {
    path_pattern {
      values = ["/milvus/*", "/milvus"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.milvus_target_group.arn
  }
}

// Attach EC2 instance to the Target Group
resource "aws_lb_target_group_attachment" "milvus_db_monitoring_attachment" {
  target_group_arn = aws_lb_target_group.milvus_target_group.arn
  target_id        = aws_instance.bastion_host.private_ip
  port             = 3000
}