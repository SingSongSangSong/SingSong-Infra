variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_username" {
  description = "The master username for the database"
  type        = string
}

variable "db_password" {
  description = "The master password for the database"
  type        = string
}

variable "db_identifier" {
  description = "The unique identifier for the database"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the RDS instance will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs for the RDS subnet group"
  type        = list(string)
}

variable "allowed_cidr_blocks" {
  description = "A list of CIDR blocks allowed to access the RDS instance"
  type        = list(string)
}

variable "db_parameter_group_name" {
  description = "The name of the DB parameter group"
  type        = string
}

variable "db_parameter_family" {
  description = "The parameter group family (e.g., mysql8.0)"
  type        = string
}

variable "parameters" {
  description = "A list of custom parameters for the RDS instance"
  type = list(object({
    name  = string
    value = string
  }))
}

variable "allocated_storage" {
  description = "The allocated storage size for the RDS instance"
  type        = number
}

variable "storage_type" {
  description = "The storage type for the RDS instance (e.g., gp3)"
  type        = string
}

variable "engine" {
  description = "The database engine (e.g., mysql)"
  type        = string
}

variable "engine_version" {
  description = "The version of the database engine"
  type        = string
}

variable "multi_az" {
  description = "Whether to deploy a Multi-AZ instance"
  type        = bool
}

variable "instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
}

variable "skip_final_snapshot" {
  description = "Whether to skip taking a final DB snapshot before deletion"
  type        = bool
}

variable "final_snapshot_identifier" {
  description = "The identifier for the final DB snapshot"
  type        = string
}

variable "ssm_password_name" {
  description = "SSM parameter name for the database password"
  type        = string
}

variable "ssm_username_name" {
  description = "SSM parameter name for the database username"
  type        = string
}

variable "ssm_endpoint_name" {
  description = "SSM parameter name for the database endpoint"
  type        = string
}

variable "subnet_group_name" {
    description = "The name of the DB subnet group"
    type        = string
}