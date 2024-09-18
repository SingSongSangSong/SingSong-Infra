# EFS for ETCD
resource "aws_efs_file_system" "etcd_efs" {
  creation_token = "etcd-file-system"
  performance_mode = "generalPurpose"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name = "etcd-efs"
  }
}

# EFS for MinIO
resource "aws_efs_file_system" "minio_efs" {
  creation_token = "minio-file-system"
  performance_mode = "generalPurpose"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name = "minio-efs"
  }
}

# EFS for Milvus
resource "aws_efs_file_system" "milvus_efs" {
  creation_token = "milvus-file-system"
  performance_mode = "generalPurpose"
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    Name = "milvus-efs"
  }
}

resource "aws_security_group" "singsong_milvus_security_group" {
  name        = "singsong-milvus-security-group"
  description = "Security group for ECS Fargate Milvus service"

  vpc_id = aws_vpc.singsong_vpc.id

  # Milvus Standalone (19530, 9091)
  ingress {
    from_port   = 19530
    to_port     = 19530
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9091
    to_port     = 9091
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ETCD (2379)
  ingress {
    from_port   = 2379
    to_port     = 2379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MinIO (9000, 9001)
  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 9001
    to_port     = 9001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Attu (3000)
  ingress {
    from_port   = 3000
    to_port     = 3000
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

resource "aws_ecs_task_definition" "milvus_ecs_task_definition" {
  family                   = "milvus-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "4096"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "milvus-etcd"
      image     = "quay.io/coreos/etcd:v3.5.5"
      essential = true
      command   = [
        "etcd",
        "-advertise-client-urls=http://127.0.0.1:2379",
        "-listen-client-urls=http://0.0.0.0:2379",
        "--data-dir=/etcd"
      ]
      environment = [
        {
          name  = "ETCD_AUTO_COMPACTION_MODE"
          value = "revision"
        },
        {
          name  = "ETCD_AUTO_COMPACTION_RETENTION"
          value = "1000"
        },
        {
          name  = "ETCD_QUOTA_BACKEND_BYTES"
          value = "4294967296"
        },
        {
          name  = "ETCD_SNAPSHOT_COUNT"
          value = "50000"
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "milvus-etcd-storage"
          containerPath = "/etcd"
        }
      ]
    },
    {
      name      = "milvus-minio"
      image     = "minio/minio:RELEASE.2023-03-20T20-16-18Z"
      essential = true
      command   = ["minio", "server", "/minio_data", "--console-address", ":9001"]
      environment = [
        {
          name  = "MINIO_ACCESS_KEY"
          value = "minioadmin"
        },
        {
          name  = "MINIO_SECRET_KEY"
          value = "minioadmin"
        }
      ]
      portMappings = [
        {
          containerPort = 9000
          hostPort      = 9000
        },
        {
          containerPort = 9001
          hostPort      = 9001
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "milvus-minio-storage"
          containerPath = "/minio_data"
        }
      ]
    },
    {
      name      = "milvus-standalone"
      image     = "milvusdb/milvus:v2.4.10"
      essential = true
      command   = ["milvus", "run", "standalone"]
      environment = [
        {
          name  = "ETCD_ENDPOINTS"
          value = "milvus-etcd:2379"
        },
        {
          name  = "MINIO_ADDRESS"
          value = "milvus-minio:9000"
        }
      ]
      portMappings = [
        {
          containerPort = 19530
          hostPort      = 19530
        },
        {
          containerPort = 9091
          hostPort      = 9091
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "milvus-storage"
          containerPath = "/var/lib/milvus"
        }
      ]
    },
    {
      name      = "attu"
      image     = "zilliz/attu:latest"
      essential = true
      environment = [
        {
          name  = "HOST_URL"
          value = "http://localhost:3000"
        },
        {
          name  = "MILVUS_URL"
          value = "milvus-standalone:19530"
        }
      ]
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])

  volume {
    name = "milvus-etcd-storage"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.etcd_efs.id
    }
  }

  volume {
    name = "milvus-minio-storage"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.minio_efs.id
    }
  }

  volume {
    name = "milvus-storage"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.milvus_efs.id
    }
  }
}

resource "aws_ecs_service" "singsong_embedding_service" {
  name                   = "singsong-ecs-embedding-service"
  cluster                = aws_ecs_cluster.singsong_ecs_cluster.id
  task_definition        = aws_ecs_task_definition.milvus_ecs_task_definition.arn
  desired_count          = 1
  launch_type            = "FARGATE"
  scheduling_strategy    = "REPLICA"
  health_check_grace_period_seconds = 120

  network_configuration {
    subnets         = [aws_subnet.singsong_public_subnet1.id, aws_subnet.singsong_public_subnet2.id]
    security_groups = [aws_security_group.singsong_milvus_security_group.id]
    assign_public_ip = true
  }
}