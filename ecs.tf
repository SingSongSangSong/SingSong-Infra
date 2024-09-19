// ECS Cluster 생성
resource "aws_ecs_cluster" "singsong_ecs_cluster" {
  name = var.ecs_cluster_name
}


// IAM Role 생성
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole2"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

// Attach the necessary policies to the IAM role
resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name   = "ecsTaskExecutionPolicy"
  role   = aws_iam_role.ecs_task_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:ListClusters",
          "ecs:ListContainerInstances",
          "ecs:DescribeContainerInstances",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets",
          "elasticfilesystem:DescribeMountTargetSecurityGroups",
          "elasticfilesystem:CreateFileSystem",
          "elasticfilesystem:DeleteFileSystem",
          "elasticfilesystem:CreateMountTarget",
          "elasticfilesystem:DeleteMountTarget",
          "elasticfilesystem:CreateAccessPoint",
          "elasticfilesystem:DeleteAccessPoint"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeInstances",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs"
        ],
        Resource = "*"
      }
    ]
  })
}

// ECS Task Definition 생성
resource "aws_ecs_task_definition" "singsong_golang_ecs_task_definition" {
  family                   = "singsong-golang-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name      = "singsong-golang-container"
      image     = "${aws_ecr_repository.singsong_golang_ecr_repository.repository_url}:latest"
      essential = true
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
      logConfiguration = {
        logDriver = "awsfirelens"
        options = {
          Name           = "datadog"
          dd_message_key = "log"
          apikey         = var.datadog_api_key
          dd_service     = "singsong-golang"
          dd_source      = "httpd"
          dd_tags        = "env:prod"
          provider       = "ecs"
          Host           = "http-intake.logs.us5.datadoghq.com"
          TLS            = "on"
        }
      },
    },
    {
      name      = "log-router"
      image     = "amazon/aws-for-fluent-bit:stable"
      essential = true
      firelensConfiguration = {
        type = "fluentbit"
        options = {
          "enable-ecs-log-metadata" = "true"
          "config-file-type": "file",
          "config-file-value": "/fluent-bit/configs/parse-json.conf"
        }
      }
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/singsong-golang"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "log-router"
        }
      }
    },
    {
      name      = "datadog-agent"
      image     = "public.ecr.aws/datadog/agent:latest"
      portMappings = [
        {
          hostPort      = 8126
          containerPort = 8126
          protocol      = "tcp"
        }
      ]
      essential = true
      environment = [
        {
          name  = "DD_API_KEY"
          value = var.datadog_api_key
        },
        {
          name  = "DD_SITE"
          value = var.datadog_url
        },
        {
          name  = "ECS_FARGATE"
          value = "true"
        },
        {
          name  = "DD_RUNTIME_SECURITY_CONFIG_ENABLED"
          value = "true"
        },
        {
          name  = "DD_RUNTIME_SECURITY_CONFIG_EBPFLESS_ENABLED"
          value = "true"
        },
        {
          name  = "DD_APM_ENABLED"
          value = "true"
        },
        {
          name  = "DD_APM_NON_LOCAL_TRAFFIC"
          value = "true"
        },
        {
          name  = "DD_ECS_LOG_ENABLED"
          value = "true"
        },
        {
          name  = "DD_LOGS_ENABLED"
          value = "true"
        },
        {
          name  = "DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL"
          value = "true"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/singsong-golang"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "datadog-agent"
        }
      },
      healthCheck = {
        command     = ["CMD-SHELL", "/probe.sh"]
        interval    = 30
        timeout     = 5
        retries     = 2
        startPeriod = 60
      }
    }
  ])
}

// ECS Service 생성
resource "aws_ecs_service" "singsong_ecs_service" {
  name                   = "singsong-ecs-goalng-service"
  cluster                = aws_ecs_cluster.singsong_ecs_cluster.id
  task_definition        = aws_ecs_task_definition.singsong_golang_ecs_task_definition.arn
  desired_count          = 2
  launch_type            = "FARGATE"
  scheduling_strategy    = "REPLICA"
  health_check_grace_period_seconds = 120

  service_registries {
    registry_arn = aws_service_discovery_service.singsong_ecs_service_golang_discovery.arn
  }


  load_balancer {
    target_group_arn = aws_lb_target_group.singsong_target_group.arn
    container_name = "singsong-golang-container"
    container_port   = 8080
  }

  network_configuration {
    subnets         = [aws_subnet.singsong_public_subnet1.id, aws_subnet.singsong_public_subnet2.id]
    security_groups = [aws_security_group.singsong_security_group.id]
    assign_public_ip = true
  }

  lifecycle {
    prevent_destroy = false
  }
}

# // Route 53 CNAME 레코드 생성 for Golang 서비스
# resource "aws_route53_record" "singsong_golang_record" {
#   zone_id = aws_route53_zone.singsong_private_zone.zone_id  // 기존 Hosted Zone ID 사용
#   name    = "golang.${var.route53_zone_name}"
#   type    = "CNAME"
#   ttl     = 300
#   records = [aws_lb.singsong_load_balancer.dns_name]  // Load Balancer의 DNS 이름을 사용
# }