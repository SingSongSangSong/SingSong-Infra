# ECS Cluster 생성
resource "aws_ecs_cluster" "this" {
  name = var.ecs_cluster_name
}

# ECS Task Definition 생성 (for multiple tasks)
resource "aws_ecs_task_definition" "tasks" {
  for_each                 = var.tasks
  family                   = each.value.family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = var.execution_role_arn

  container_definitions = templatefile("${path.module}/templates/${each.value.container_definitions_template}", each.value.container_variables)
}

# ECS Service 생성 (for multiple services)
resource "aws_ecs_service" "services" {
  for_each                 = var.services
  name                     = each.value.name
  cluster                  = aws_ecs_cluster.this.id
  task_definition          = aws_ecs_task_definition.tasks[each.value.task_key].arn
  desired_count            = each.value.desired_count
  launch_type              = "FARGATE"
  scheduling_strategy      = "REPLICA"
  health_check_grace_period_seconds = 120

  # Optional Service Discovery
  dynamic "service_registries" {
    for_each = try([each.value.service_discovery_arn], [])
    content {
      registry_arn = service_registries.value
    }
  }

  # Optional Load Balancer Configuration
  dynamic "load_balancer" {
    for_each = try([each.value.target_group_arn], [])
    content {
      target_group_arn = load_balancer.value
      container_name   = each.value.container_name
      container_port   = each.value.container_port
    }
  }

  network_configuration {
    subnets         = each.value.subnet_ids
    security_groups = each.value.security_group_ids
    assign_public_ip = true
  }
}