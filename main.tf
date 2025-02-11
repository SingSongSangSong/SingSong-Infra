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
  region = "ap-northeast-2" # 원하는 AWS 리전을 입력하세요
}

module "base" {
  source = "./modules/base"
  CERTIFICATE_URL = var.CERTIFICATE_URL
  PRIVATE_KEY_URL = var.PRIVATE_KEY_URL
  VPC_NAME = var.VPC_NAME
}

## ECS Module 생성
module "ecs" {
  source = "./modules/ecs"

  VPC_ID = module.base.vpc_id
  VPC_PUBLIC_SUBNETS = module.base.public_subnets
  SIGNED_CERT_ARN = module.base.signed_cert_arn
  ECR_REPOSITORY_URL = module.base.ecr_repository_url
  SECURITY_RULES_URL = var.SECURITY_RULES_URL
  TARGET_GROUPS_URL = var.TARGET_GROUPS_URL
}

resource "aws_security_group" "singsong_db_security_group" {
  name        = "singsong-db-sg"
  description = "Security group for RDS database"
  vpc_id      = module.base.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "singsong-db-sg"
  }
}

## RDS를 만든다.
module "db" {
  source            = "terraform-aws-modules/rds/aws"
  identifier        = "singsong-db"
  engine            = "mysql"
  engine_version    = "8.0.40"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name                = "singsongdb"
  username               = var.DB_USERNAME
  password               = var.DB_PASSWORD
  port                   = "3306"
  vpc_security_group_ids = [aws_security_group.singsong_db_security_group.id]

  major_engine_version = "8.0"

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.base.private_subnets

  family = "mysql8.0"
}

## ElastiCache를 만든다.
# Security Group 생성 (ElastiCache용)
resource "aws_security_group" "elasticache_sg" {
  name        = "elasticache-sg"
  description = "Security group for ElastiCache Serverless"
  vpc_id      = module.base.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "elasticache-security-group"
  }
}
resource "aws_kms_key" "elasticache_kms" {
  description             = "KMS key for ElastiCache encryption"
  deletion_window_in_days = 7
}
# ElastiCache Serverless 적용
module "elasticache" {
  source = "terraform-aws-modules/elasticache/aws//modules/serverless-cache"

  engine     = "redis"
  cache_name = "example-serverless-cache"

  cache_usage_limits = {
    data_storage = {
      maximum = 2
    }
    ecpu_per_second = {
      maximum = 1000
    }
  }

  daily_snapshot_time  = "22:00"
  description          = "singsongsangsong serverless cluster"
  kms_key_id           = aws_kms_key.elasticache_kms.arn
  major_engine_version = "7"

  security_group_ids = [aws_security_group.elasticache_sg.id]
  subnet_ids         = module.base.private_subnets

  snapshot_retention_limit = 7
}

## S3를 만든다.




