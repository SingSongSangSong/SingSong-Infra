variable "target_group_name" {
  description = "Name of the Target Group"
  type        = string
}

variable "target_group_port" {
  description = "Port for the Target Group"
  type        = number
}

variable "target_group_protocol" {
  description = "Protocol for the Target Group (e.g., HTTP, HTTPS)"
  type        = string
}

variable "target_type" {
  description = "Target type for the Target Group (e.g., instance, ip)"
  type        = string
  default     = "ip"
}

variable "deregistration_delay" {
  description = "Delay in seconds before deregistering a target"
  type        = number
  default     = 5
}

variable "health_check_path" {
  description = "Path for health checks"
  type        = string
  default     = "/"
}

variable "health_check_protocol" {
  description = "Protocol for health checks"
  type        = string
  default     = "HTTP"
}

variable "health_check_matcher" {
  description = "Expected response code for health checks"
  type        = string
  default     = "200"
}

variable "health_check_interval" {
  description = "Interval for health checks in seconds"
  type        = number
  default     = 150
}

variable "health_check_timeout" {
  description = "Timeout for health checks in seconds"
  type        = number
  default     = 120
}

variable "healthy_threshold" {
  description = "Number of successful checks before marking target as healthy"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Number of failed checks before marking target as unhealthy"
  type        = number
  default     = 3
}

variable "lb_name" {
  description = "Name of the Load Balancer"
  type        = string
}

variable "lb_internal" {
  description = "Whether the Load Balancer is internal or not"
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "Security Groups to attach to the Load Balancer"
  type        = list(string)
}

variable "subnets" {
  description = "Subnets to attach to the Load Balancer"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "Whether to enable deletion protection for the Load Balancer"
  type        = bool
  default     = false
}

variable "http_listener_port" {
  description = "Port for the HTTP Listener"
  type        = number
  default     = 80
}

variable "https_listener_port" {
  description = "Port for the HTTPS Listener"
  type        = number
  default     = 443
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS"
  type        = string
}

variable "vpc_id" {
    description = "ID of the VPC"
    type        = string
}