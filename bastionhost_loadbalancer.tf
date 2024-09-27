resource "aws_lb_target_group_attachment" "singsong_3000_target_attachment" {
  target_group_arn = aws_lb_target_group.singsong_3000_target_group.arn
  target_id        = aws_instance.bastion_host.private_ip  # EC2 인스턴스의 프라이빗 IP 주소
  port             = 3000
}

// Load Balancer Target Group for port 3000 (Attu)
resource "aws_lb_target_group" "singsong_3000_target_group" {
  name     = "3000-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.singsong_vpc.id
  target_type = "ip"
  deregistration_delay = "5"
}

// Load Balancer 생성
resource "aws_lb" "singsong_bastion_load_balancer" {
  name               = "singsong-bastion-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.bastion_sg.id]
  subnets            = [aws_subnet.singsong_public_subnet1.id, aws_subnet.singsong_public_subnet2.id]

  enable_deletion_protection = false
}

// Load Balancer Listener for HTTP -> HTTPS redirect on port 80 (default action)
resource "aws_lb_listener" "singsong_bastion_listener" {
  load_balancer_arn = aws_lb.singsong_bastion_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

// Load Balancer Listener for HTTPS on port 443 (redirects HTTP to HTTPS)
resource "aws_lb_listener" "singsong_bastion_listener_https" {
  load_balancer_arn = aws_lb.singsong_bastion_load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.singsong_bastion_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.singsong_3000_target_group.arn
  }
}
