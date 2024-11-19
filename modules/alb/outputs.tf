output "load_balancer_arn" {
  description = "ARN of the Load Balancer"
  value       = aws_lb.this.arn
}

output "load_balancer_dns_name" {
  description = "DNS Name of the Load Balancer"
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "ARN of the Target Group"
  value       = aws_lb_target_group.this.arn
}