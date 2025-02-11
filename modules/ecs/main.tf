locals {
  security_rules = jsondecode(file(var.SECURITY_RULES_URL))
  target_groups  = jsondecode(file(var.TARGET_GROUPS_URL))
}
# ## ALB Listener에 사용할 Self-Signed Certificate를 만든다
resource "aws_iam_server_certificate" "self_signed_cert" {
  name_prefix   = "test-cert"
  certificate_body = file("/Users/sunwupark/Documents/SingSong-Infra/json/certificate/certificate.crt")
  private_key      = file("/Users/sunwupark/Documents/SingSong-Infra/json/certificate/private.key")
}

## ALB 생성
module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = "singsong-alb"
  vpc_id  = var.VPC_ID
  subnets = var.VPC_PUBLIC_SUBNETS

  security_group_ingress_rules = local.security_rules["security_group_ingress_rules"]
  security_group_egress_rules  = local.security_rules["security_group_egress_rules"]

  listeners = {
    "ex-http-https-redirect" = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
    "ex-https" = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = aws_iam_server_certificate.self_signed_cert.arn
      forward = {
        target_group_key = "ex-ecs"
      }
    }
  }

  target_groups = local.target_groups
  enable_deletion_protection = false

  tags = {
    Terraform   = "true"
    Environment = "Test"
  }
}

## ECS Cluster 생성
resource "aws_ecs_cluster" "singsong-ecs-cluster" {
  name = "singsong-ecs-cluster"
}

## ECS Task Execution Role (IAM Role) 생성
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

## Task Execution Role에 필요한 정책 추가
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

## ECS Task 생성
resource "aws_ecs_task_definition" "singsong-ecs-task" {
  family                   = "singsong-service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = 1024
  memory                   = 2048

  container_definitions = jsonencode([
    {
      name      = "fluent-bit"
      cpu       = 512
      memory    = 1024
      essential = true
      image     = "906394416424.dkr.ecr.us-west-2.amazonaws.com/aws-for-fluent-bit:stable"

      firelens_configuration = {
        type = "fluentbit"
      }

      memory_reservation = 50
    },
    {
      name      = "singsong-golang-container"
      cpu       = 256
      memory    = 512
      essential = true
#       image     = var.ECR_REPOSITORY_URL  # ✅ ECR URL을 Terraform 변수로 적용
      image     = "nginx:latest"

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        },
        {
          containerPort = 80
          hostPort      = 80
        }
      ]

      dependencies = [
        {
          containerName = "fluent-bit"
          condition     = "START"
        }
      ]

      enable_cloudwatch_logging = false

      log_configuration = {
        logDriver = "awsfirelens"
        options = {
          Name                     = "firehose"
          region                   = "eu-west-1"
          delivery_stream          = "my-stream"
          log-driver-buffer-limit  = "2097152"
        }
      }

      memory_reservation = 100
    }
  ])
}
# SNS Topic 생성 (ECS 배포 알람을 위한 SNS)
resource "aws_sns_topic" "ecs_deployment_alarm" {
  name = "ecs-deployment-alarm"
}

# SNS Topic 구독 (이메일 알림)
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.ecs_deployment_alarm.arn
  protocol  = "email"
  endpoint  = "sunwu5678@gmail.com"  # 이메일 주소 입력
}

# SNS에 메시지를 보낼 수 있도록 EventBridge에 권한 부여
resource "aws_sns_topic_policy" "sns_eventbridge_policy" {
  arn = aws_sns_topic.ecs_deployment_alarm.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.ecs_deployment_alarm.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.ecs_service_status_alerts.arn
          }
        }
      }
    ]
  })
}

# EventBridge Rule 생성 (ECS 서비스 상태 변경 감지)
resource "aws_cloudwatch_event_rule" "ecs_service_status_alerts" {
  name        = "ecs-service-status-alerts"
  description = "Capture ECS service state changes and alert on failures"

  event_pattern = <<EOF
{
  "source": ["aws.ecs"],
  "detail-type": ["ECS Service Action", "ECS Task State Change"],
  "detail": {
    "eventName": [
      "SERVICE_STEADY_STATE",
      "TASKS_STOPPED",
      "SERVICE_DEPLOYMENT_COMPLETED",
      "SERVICE_TASK_START_IMPAIRED",
      "SERVICE_DISCOVERY_INSTANCE_UNHEALTHY",
      "SERVICE_TASK_PLACEMENT_FAILURE",
      "SERVICE_TASK_CONFIGURATION_FAILURE",
      "SERVICE_DEPLOYMENT_FAILED"
    ]
  }
}
EOF
}

# EventBridge -> SNS로 알림 전송
resource "aws_cloudwatch_event_target" "ecs_deployment_target" {
  rule      = aws_cloudwatch_event_rule.ecs_service_status_alerts.name
  target_id = "ecs-sns"
  arn       = aws_sns_topic.ecs_deployment_alarm.arn
}

## 보안 그룹 생성 (ECS 컨테이너 직접 접근 가능하도록 설정)
resource "aws_security_group" "test_sg" {
  name   = "test-ecs-sg"
  vpc_id = var.VPC_ID

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## ECS Service 생성
resource "aws_ecs_service" "singsong-ecs-service" {
  name            = "singsong-service"
  cluster         = aws_ecs_cluster.singsong-ecs-cluster.id
  task_definition = aws_ecs_task_definition.singsong-ecs-task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.VPC_PUBLIC_SUBNETS
    security_groups  = [aws_security_group.test_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = module.alb.target_groups["ex-ecs"].arn
    container_name   = "singsong-golang-container"
    container_port   = 80
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  depends_on = [module.alb]
}