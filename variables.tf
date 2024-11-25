variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
}

variable "ecs_cluster_name" {
  description = "ECS Cluster name"
  type        = string
}

variable "db_username" {
  description = "RDS instance username"
  type        = string
}

variable "db_password" {
  description = "RDS instance password"
  type        = string
}

variable "db_name" {
    description = "RDS instance name"
    type        = string
}

variable "datadog_api_key" {
  description = "Datadog API key"
  type        = string
}

variable "datadog_url" {
  description = "Datadog site"
  type        = string
}

variable "datadog_key_id" {
  description = "Datadog key id"
  type        = string
}

variable "certificate_domain" {
  description = "Domain for the ACM certificate"
  type        = string
}

variable "route53_zone_name" {
  description = "Route 53 hosted zone name"
  type        = string
}

variable "existing_route53_zone_name" {
  description = "Existing Route 53 hosted zone name"
  type        = string
}

variable "key_name" {
    description = "Key pair name"
    type        = string
}

variable "public_key" {
    description = "Public key for the key pair"
    type        = string
}

variable "s3_bucket_name" {
    description = "S3 bucket name"
    type        = string
}

variable "openai_api_key" {
    description = "OpenAI API key"
    type        = string
}

variable "langchain_tracing_v2" {
    description = "Langchain tracing v2"
    type        = string
}

variable "langchain_endpoint" {
    description = "Langchain endpoint"
    type        = string
}

variable "langchain_api_key" {
    description = "Langchain API key"
    type        = string
}

variable "langchain_project" {
    description = "Langchain project"
    type        = string
}

variable "milvus_host" {
    description = "Milvus host"
    type        = string
}

variable "PINECONE_API_KEY" {
  type        = string
  description = "API key for Pinecone"
}

variable "PINECONE_INDEX" {
  type        = string
  description = "Index for Pinecone"
}

variable "DB_PORT" {
  type        = number
  description = "Database port"
}

variable "REDIS_PASSWORD" {
    type        = string
    description = "Redis password"
}

variable "SECRET_KEY" {
  type        = string
  description = "Secret key for application"
  sensitive   = true
}

variable "KAKAO_REST_API_KEY" {
  type        = string
  description = "Kakao REST API key"
}

variable "KAKAO_ISSUER" {
  type        = string
  description = "Kakao issuer URL"
}

variable "JWT_ISSUER" {
  type        = string
  description = "JWT issuer"
}

variable "JWT_ACCESS_VALIDITY_SECONDS" {
  type        = string
  description = "JWT access token validity in seconds"
}

variable "JWT_REFRESH_VALIDITY_SECONDS" {
  type        = string
  description = "JWT refresh token validity in seconds"
}

variable "REDIS_PORT" {
    type        = string
    description = "Redis port"
}

variable "GRPC_ADDR" {
    type        = string
    description = "GRPC address"
}

variable "APPLE_ISSUER"{
    type        = string
    description = "Apple issuer"
}

variable "APPLE_CLIENT_ID"{
    type        = string
    description = "Apple client id"
}

variable "MINIO_ROOT_USER" {
    type        = string
    description = "Minio root user"
}

variable "MINIO_ROOT_PASSWORD" {
    type        = string
    description = "Minio root password"
}

variable "PRIVATE_KEY" {
  type        = string
  description = "Private"
}

variable "BASTION_ZONE_NAME" {
    type        = string
    description = "Bastion zone name"
}

variable "BASTION_CERTIFICATE_DOMAIN" {
  type        = string
  description = "Bastion certification domain name"
}

variable "MILVUS_PORT" {
  type        = string
  description = "Milvus port"
}

variable "MILVUS_COLLECTION_NAME" {
  type        = string
  description = "Milvus collection name"
}

variable "MILVUS_DIMENSION" {
    type        = string
    description = "Milvus dimension"
}

variable "GOOGLE_APPLICATION_CREDENTIALS_PATH" {
    type        = string
    description = "Google application credentials path for fcm"
}

variable "DEEP_LINK_BASE" {
    type        = string
    description = "Deep link base"
}

variable "SSM_PARAMETER_SERVICE_ACCOUNT" {
  type = string
  description = "Service account in parameter store"
}

variable "SENTRY_DSN" {
  type = string
  description = "Sentry DSN"
}