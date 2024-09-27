// ECS Task Definition 생성
resource "aws_ecs_task_definition" "singsong_embedding_ecs_task_definition" {
  family                   = "singsong-embedding-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = jsonencode([
    {
      name      = "singsong-embedding-container"
      image     = "${aws_ecr_repository.singsong_embedding_ecr_repository.repository_url}:latest"
      essential = true
      environment = [
        {
          name  = "DB_HOST"
          value = element(split(":", aws_db_instance.singsong_db.endpoint), 0)
        },
        {
          name  = "DB_USER"
          value = var.db_username
        },
        {
          name  = "DB_PASSWORD"
          value = var.db_password
        },
        {
          name  = "DB_DATABASE"
          value = var.db_name
        },
        {
          name  = "OPENAI_API_KEY"
          value = var.openai_api_key
        },
        {
          name  = "LANGCHAIN_TRACING_V2"
          value = var.langchain_tracing_v2
        },
        {
          name  = "LANGCHAIN_ENDPOINT"
          value = var.langchain_endpoint
        },
        {
          name  = "LANGCHAIN_API_KEY"
          value = var.langchain_api_key
        },
        {
          name  = "LANGCHAINPROJECT"
          value = var.langchain_project
        },
        {
          name = "REDIS_HOST"
          value = split(":", aws_elasticache_cluster.singsong_redis.cache_nodes.0.address)[0]
        },
        {
          name = "MILVUS_HOST"
          value = aws_eip.bastion_eip.public_ip
        }
      ],
      portMappings = [
        {
          containerPort = 50051
          hostPort      = 50051
        }
      ]
      logConfiguration = {
        logDriver = "awsfirelens"
        options = {
          Name           = "datadog"
          dd_message_key = "log"
          apikey         = var.datadog_api_key
          dd_service     = "singsong-embedding"
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
          "awslogs-group"         = "/ecs/singsong-embedding"
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
          "awslogs-group"         = "/ecs/singsong-embedding"
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

// ECS Service 생성 for Embedding Service
resource "aws_ecs_service" "singsong_embedding_service" {
  name                = "singsong-ecs-embedding-service"
  cluster             = aws_ecs_cluster.singsong_ecs_cluster.id
  task_definition     = aws_ecs_task_definition.singsong_embedding_ecs_task_definition.arn
  desired_count       = 1
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  network_configuration {
    subnets = [aws_subnet.singsong_public_subnet1.id, aws_subnet.singsong_public_subnet2.id]
    security_groups = [aws_security_group.singsong_security_group.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.singsong_ecs_service_embedding_discovery.arn
  }

}