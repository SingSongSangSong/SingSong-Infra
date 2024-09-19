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