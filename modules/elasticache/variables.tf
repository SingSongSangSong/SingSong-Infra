variable "subnet_group_name" {
  description = "Name of the ElastiCache Subnet Group"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Redis Subnet Group"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the Redis Security Group"
  type        = string
}

variable "ingress_cidr_blocks" {
  description = "CIDR blocks allowed to access the Redis Security Group"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "redis_port" {
  description = "Port for Redis"
  type        = number
  default     = 6379
}

variable "cluster_id" {
  description = "Unique identifier for the Redis cluster"
  type        = string
}

variable "node_type" {
  description = "The instance type for Redis nodes"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "Number of cache nodes in the Redis cluster"
  type        = number
  default     = 1
}

variable "apply_immediately" {
  description = "Whether to apply changes immediately"
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  description = "Identifier for the final snapshot of the Redis cluster"
  type        = string
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group for Redis logs"
  type        = string
}

variable "ssm_parameter_name" {
  description = "Name of the SSM parameter to store the Redis endpoint"
  type        = string
}