output "vpc_id" {
    description = "The VPC ID where the RDS instance is deployed"
    value       = aws_vpc.this.id
}

output "public_subnet_ids" {
    description = "A list of subnet IDs for the RDS subnet group"
    value       = [aws_subnet.public1.id, aws_subnet.public2.id]
}

output "private_subnet_ids" {
    description = "A list of subnet IDs for the RDS subnet group"
    value       = [aws_subnet.private1.id, aws_subnet.private2.id]
}