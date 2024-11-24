// Redis Subnet Group
resource "aws_elasticache_subnet_group" "this" {
  name       = var.subnet_group_name
  subnet_ids = var.subnet_ids
}

// Redis Security Group
resource "aws_security_group" "this" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.redis_port
    to_port     = var.redis_port
    protocol    = "tcp"
    cidr_blocks = var.ingress_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// Redis Cluster
resource "aws_elasticache_cluster" "this" {
  cluster_id        = var.cluster_id
  engine            = "redis"
  node_type         = var.node_type
  num_cache_nodes   = var.num_cache_nodes
  port              = var.redis_port
  apply_immediately = var.apply_immediately
  subnet_group_name = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.this.id]
  final_snapshot_identifier = var.final_snapshot_identifier

  log_delivery_configuration {
    destination      = var.log_group_name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }
}

// SSM Parameter for Redis Endpoint
resource "aws_ssm_parameter" "endpoint" {
  name  = var.ssm_parameter_name
  type  = "String"
  value = split(":", aws_elasticache_cluster.this.cache_nodes[0].address)[0]
}