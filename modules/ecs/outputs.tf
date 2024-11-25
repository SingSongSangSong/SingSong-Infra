output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "task_definition_arns" {
  description = "ARNs of the ECS Task Definitions"
  value       = { for k, v in aws_ecs_task_definition.tasks : k => v.arn }
}

output "service_names" {
  description = "Names of the ECS Services"
  value       = { for k, v in aws_ecs_service.services : k => v.name }
}