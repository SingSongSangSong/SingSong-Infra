output "redis_cluster_id" {
  description = "The ID of the Redis cluster"
  value       = aws_elasticache_cluster.this.id
}

output "redis_endpoint" {
  description = "The endpoint of the Redis cluster"
  value       = aws_elasticache_cluster.this.cache_nodes[0].address
}

output "redis_security_group_id" {
  description = "The ID of the Redis security group"
  value       = aws_security_group.this.id
}