// ECS Task Definition 생성
resource "aws_ecs_task_definition" "singsong_milvus_task_definition" {
  family                   = "singsong-milvus-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "4096"
  memory                   = "16384"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "milvus-standalone"
      image     = "milvusdb/milvus:v2.4.5"  # Milvus 이미지 사용
      essential = true
      portMappings = [
        {
          containerPort = 19530  # Milvus의 gRPC 포트
          hostPort      = 19530
        },
        {
          containerPort = 9091   # Milvus의 RESTful API 포트
          hostPort      = 9091
        },
        {
          containerPort = 2379   # Milvus의 etcd 포트
          hostPort      = 2379
        }
      ]
      environment = [
        {
          name  = "ETCD_USE_EMBED"
          value = "true"
        },
        {
          name  = "ETCD_DATA_DIR"
          value = "/var/lib/milvus/etcd"
        },
        {
          name  = "ETCD_CONFIG_PATH"
          value = "/milvus/configs/embedEtcd.yaml"
        },
        {
          name  = "COMMON_STORAGETYPE"
          value = "local"
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "milvus-data"
          containerPath = "/var/lib/milvus"
          readOnly      = false
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/singsong-milvus-task"
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  volume {
    name = "milvus-data"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.milvus_efs.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
    }
  }
}

// EFS 파일 시스템 생성
resource "aws_efs_file_system" "milvus_efs" {
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS" // 데이터를 30일 동안 액세스하지 않으면 Infrequent Access 클래스로 전환
  }

  encrypted = true
  tags = {
    Name = "milvus-efs"
  }
}

// EFS 마운트 대상 생성
resource "aws_efs_mount_target" "milvus_efs_mount_target" {
  count           = length(aws_subnet.singsong_private_subnet1.id)
  file_system_id  = aws_efs_file_system.milvus_efs.id
  subnet_id       = element([aws_subnet.singsong_private_subnet1.id, aws_subnet.singsong_private_subnet2.id], count.index)
  security_groups = [aws_security_group.efs_sg.id]
}

// 보안 그룹 생성 (EFS 접근용)
resource "aws_security_group" "efs_sg" {
  name        = "efs-security-group"
  description = "Allow NFS access to EFS"
  vpc_id      = aws_vpc.singsong_vpc.id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.singsong_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// ECS Service 생성
resource "aws_ecs_service" "singsong_milvus_service" {
  name            = "singsong-milvus-service"
  cluster         = aws_ecs_cluster.singsong_ecs_cluster.id
  task_definition = aws_ecs_task_definition.singsong_milvus_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = [aws_subnet.singsong_private_subnet1.id, aws_subnet.singsong_private_subnet2.id]
    security_groups = [aws_security_group.efs_sg.id]
  }
}