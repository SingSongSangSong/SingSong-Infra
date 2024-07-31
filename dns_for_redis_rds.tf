// Route 53 Hosted Zone 생성
resource "aws_route53_zone" "singsong_zone" {
  name = var.route53_zone_name
}

// Route 53 CNAME 레코드 생성 for RDS
resource "aws_route53_record" "singsong_rds_record" {
  zone_id = aws_route53_zone.singsong_zone.zone_id
  name    = "db.${var.route53_zone_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_db_instance.singsong_db.endpoint]
}
// Route 53 CNAME 레코드 생성 for Redis
resource "aws_route53_record" "singsong_redis_record" {
  zone_id = aws_route53_zone.singsong_zone.zone_id
  name    = "redis.${var.route53_zone_name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_elasticache_cluster.singsong_redis.cache_nodes.0.address]
}