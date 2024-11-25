variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the execution role for ECS Task"
  type        = string
}

variable "tasks" {
  description = "Configuration for ECS Task Definitions"
  type = map(object({
    family                        = string
    cpu                           = string
    memory                        = string
    container_definitions_template = string
    container_variables           = map(any)
  }))
}

variable "services" {
  description = "Configuration for ECS Services"
  type = map(object({
    name                   = string
    task_key               = string
    desired_count          = number
    service_discovery_arn  = optional(string) # Optional Service Discovery ARN
    target_group_arn       = optional(string) # Optional Target Group ARN
    container_name         = string
    container_port         = number
    subnet_ids             = list(string)
    security_group_ids     = list(string)
  }))
}