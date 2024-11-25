output "ec2_eip" {
    description = "The EIP of the bastion instance"
    value       = aws_eip.bastion_eip.public_ip
}