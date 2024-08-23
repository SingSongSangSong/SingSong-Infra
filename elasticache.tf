resource "aws_elasticache_subnet_group" "singsong_redis_subnet_group" {
  name = "singsong-redis-subnet-group"
  subnet_ids = [aws_subnet.singsong_private_subnet1.id, aws_subnet.singsong_private_subnet2.id]
}

resource "aws_elasticache_cluster" "singsong_redis" {
  cluster_id        = "singsong-redis"
  engine            = "redis"
  node_type         = "cache.t3.micro"
  num_cache_nodes   = 1
  port              = 6379
  apply_immediately = true
  subnet_group_name = aws_elasticache_subnet_group.singsong_redis_subnet_group.name
  security_group_ids = [aws_security_group.redis_sg.id]
  final_snapshot_identifier = "singsong-redis-final-snapshot"
  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.singsong_log_group.name
    destination_type = "cloudwatch-logs"
    log_format       = "text"
    log_type         = "slow-log"
  }
}