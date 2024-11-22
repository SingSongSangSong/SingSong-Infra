terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "swm_sunwupark"
    workspaces {
      name = "singsong-state-project"
    }
  }
}

provider "aws" {
  region = var.region
}

module "iam" {
  source       = "modules/iam"
  role_name    = "ecsTaskExecutionRole"
  policy_document = {
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
          "s3:PutObject",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:DescribeParameters",
          "kms:Decrypt"
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
  }
}

module "ecs" {
  source             = "modules/ecs"
  ecs_cluster_name   = "singsong-cluster"
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  tasks = {
    golang = {
      family                        = "singsong-golang-task"
      cpu                           = "1024"
      memory                        = "2048"
      container_definitions_template = "golang_task.yml.tpl"
      container_variables = {
        ecr_repository_url = aws_ecr_repository.singsong_golang_ecr_repository.repository_url
        db_host            = element(split(":", module.rds.db_instance_endpoint), 0) # RDS 호스트
        db_username        = var.db_username # DB 사용자 이름
        db_password        = var.db_password # DB 비밀번호
        db_name            = var.db_name # DB 이름
        db_port            = tostring(var.DB_PORT) # DB 포트
        redis_host         = split(":", module.redis.redis_endpoint)[0] # Redis 호스트
        milvus_host        = module.ec2.ec2_eip # Milvus 호스트
        datadog_api_key    = var.datadog_api_key # Datadog API Key
        datadog_url        = var.datadog_url # Datadog URL
        aws_region         = var.region # AWS 리전
        redis_port         = "6379" # Redis 포트 (고정값)
        redis_password     = var.REDIS_PASSWORD # Redis 비밀번호
        pinecone_api_key   = var.PINECONE_API_KEY # Pinecone API Key
        pinecone_index     = var.PINECONE_INDEX # Pinecone Index
        secret_key         = var.SECRET_KEY # 애플리케이션 비밀 키
        kakao_rest_api_key = var.KAKAO_REST_API_KEY # Kakao REST API Key
        kakao_issuer       = var.KAKAO_ISSUER # Kakao Issuer
        jwt_issuer         = var.JWT_ISSUER # JWT Issuer
        jwt_access_validity_seconds = var.JWT_ACCESS_VALIDITY_SECONDS # JWT Access Token 유효 기간
        jwt_refresh_validity_seconds = var.JWT_REFRESH_VALIDITY_SECONDS # JWT Refresh Token 유효 기간
        grpc_addr          = var.GRPC_ADDR # gRPC 주소
        apple_issuer       = var.APPLE_ISSUER # Apple Issuer
        apple_client_id    = var.APPLE_CLIENT_ID # Apple Client ID
        milvus_port        = var.MILVUS_PORT # Milvus 포트
        milvus_collection_name = var.MILVUS_COLLECTION_NAME # Milvus 컬렉션 이름
        milvus_dimension   = var.MILVUS_DIMENSION # Milvus 벡터 차원
#         aws_access_key_id  = var.aws_access_key_id # AWS 액세스 키 ID
#         aws_secret_access_key = var.aws_secret_access_key # AWS 비밀 키
        s3_bucket_name     = var.s3_bucket_name # S3 버킷 이름
        google_application_credentials = var.GOOGLE_APPLICATION_CREDENTIALS_PATH # Google Application Credentials 경로
        deep_link_base     = var.DEEP_LINK_BASE # 딥 링크 기본 URL
        ssm_parameter_service_account = var.SSM_PARAMETER_SERVICE_ACCOUNT # SSM 파라미터 서비스 계정
      }
    },
    embedding = {
      family                        = "singsong-embedding-task"
      cpu                           = "2048"
      memory                        = "4096"
      container_definitions_template = "embedding_task.yml.tpl"
      container_variables = {
        ecr_repository_url = aws_ecr_repository.singsong_embedding_ecr_repository.repository_url
        db_host            = element(split(":", module.rds.db_instance_endpoint), 0)
        db_username        = var.db_username
        db_password        = var.db_password
        db_name            = var.db_name
        openai_api_key     = var.openai_api_key
        langchain_tracing_v2 = var.langchain_tracing_v2
        langchain_endpoint = var.langchain_endpoint
        langchain_api_key  = var.langchain_api_key
        langchain_project  = var.langchain_project
        redis_host         = split(":", module.redis.redis_endpoint)[0]
        milvus_host        = module.ec2.ec2_eip
        datadog_api_key    = var.datadog_api_key
        datadog_url        = var.datadog_url
        aws_region         = var.region
      }
    }
  }

  services = {
    golang_service = {
      name                   = "singsong-ecs-golang-service"
      task_key               = "golang"
      desired_count          = 2
      service_discovery_arn  = aws_service_discovery_service.singsong_ecs_service_golang_discovery.arn
      target_group_arn       = module.load_balancer.target_group_arn
      container_name         = "singsong-golang-container"
      container_port         = 8080
      subnet_ids             = [module.vpc.public_subnet_ids]
      security_group_ids     = [module.ec2_sg.security_group_id]
    },
    embedding_service = {
      name                   = "singsong-ecs-embedding-service"
      task_key               = "embedding"
      desired_count          = 1
      service_discovery_arn  = aws_service_discovery_service.singsong_ecs_service_embedding_discovery.arn
      container_name         = "singsong-embedding-container"
      container_port         = 50051
      subnet_ids             = [module.vpc.public_subnet_ids]
      security_group_ids     = [module.ec2_sg.security_group_id]
    }
  }
}


module "vpc" {
  source = "modules/vpc"

  vpc_cidr_block = var.vpc_cidr_block
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks
  region = var.region
# availability_zones = var.
  vpc_name = "singsong-vpc"
  public_subnet_names = ["singsong-public-subnet1", "singsong-public-subnet2"]
  private_subnet_names = ["singsong-private-subnet1", "singsong-private-subnet2"]
  igw_name = "singsong-igw"
  public_route_table_name = "singsong-public-route-table"
  private_route_table_name = "singsong-private-route-table"
}

// Cloud Map 네임스페이스 생성 (기존 Hosted Zone 이름과 연동)
resource "aws_service_discovery_private_dns_namespace" "singsong_ecs_service_discovery_namespace" {
  name  = var.route53_zone_name  // 기존 Route 53 Hosted Zone 이름을 사용
  vpc   = module.vpc.vpc_id
}

module "ec2" {
  source = "modules/ec2"

  vpc_id = module.vpc.vpc_id
  public_subnet1_id = module.vpc.public_subnet_ids[0]
  ec2_key_name = var.key_name
  ec2_public_key = var.public_key
  ec2_private_key = var.PRIVATE_KEY
  instance_type = "c6g.xlarge"
  allowed_cidr_blocks = var.vpc_cidr_block
  bastion_host_name = "bastion-host"
}

module "ec2_sg" {
  source = "modules/security_group"

  security_group_name = "bastion-sg"
  security_group_vpc_id              = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 8126
      to_port     = 8126
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 50051
      to_port     = 50051
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  tags = {
    Environment = "production"
    Name        = "bastion-sg"
  }
}

module "load_balancer" {
  source = "modules/alb"

  target_group_name      = "singsong-target-group"
  target_group_port      = 8080
  target_group_protocol  = "HTTP"
  vpc_id                 = module.vpc.vpc_id
  target_type            = "ip"

  lb_name                = "singsong-load-balancer"
  lb_internal            = false
  security_groups        = [module.ec2_sg.security_group_id]
  subnets                = module.vpc.public_subnet_ids

  certificate_arn        = data.aws_acm_certificate.singsong_cert.arn
}

module "rds" {
  source = "modules/rds"

  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  db_identifier           = var.DB_IDENTIFIER
  vpc_id                  = module.vpc.vpc_id
  subnet_ids              = module.vpc.private_subnet_ids[0]
  allowed_cidr_blocks     = var.vpc_cidr_block
  db_parameter_group_name = "singsong-db-parameter-group"
  db_parameter_family     = "mysql8.0"
  parameters = [
    { name = "character_set_server", value = "utf8mb4" },
    { name = "collation_server", value = "utf8mb4_unicode_ci" },
    { name = "time_zone", value = "Asia/Seoul" },
  ]
  allocated_storage       = 30
  storage_type            = "gp3"
  engine                  = "mysql"
  engine_version          = "8.0.35"
  multi_az                = true
  instance_class          = "db.t4g.micro"
  skip_final_snapshot     = true
  final_snapshot_identifier = "singsong-final-snapshot"
  ssm_password_name       = "/singsong/RDSPassword"
  ssm_username_name       = "/singsong/RDSUsername"
  ssm_endpoint_name       = "/singsong/RDSEndpoint"
  subnet_group_name       = "singsong-db-subnet-group"
}

module "redis" {
  source = "modules/elastiCache"

  subnet_group_name       = "singsong-redis-subnet-group"
  subnet_ids              = module.vpc.private_subnet_ids
  vpc_id                  = module.vpc.vpc_id
  ingress_cidr_blocks     = var.vpc_cidr_block
  cluster_id              = "singsong-redis"
  node_type               = "cache.t3.micro"
  num_cache_nodes         = 1
  apply_immediately       = true
  final_snapshot_identifier = "singsong-redis-final-snapshot"
  log_group_name          = aws_cloudwatch_log_group.singsong_log_group.name
  ssm_parameter_name      = "/singsong/ElastiCacheEndpoint"
}