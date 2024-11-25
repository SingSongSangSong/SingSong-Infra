variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "ap-northeast-2" # Default is Seoul region
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["ap-northeast-2a", "ap-northeast-2c"] # Default zones in Seoul region
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "public_subnet_names" {
  description = "Names for public subnets"
  type        = list(string)
}

variable "private_subnet_names" {
  description = "Names for private subnets"
  type        = list(string)
}

variable "igw_name" {
  description = "Name tag for the Internet Gateway"
  type        = string
}

variable "public_route_table_name" {
  description = "Name tag for the public route table"
  type        = string
}

variable "private_route_table_name" {
  description = "Name tag for the private route table"
  type        = string
}