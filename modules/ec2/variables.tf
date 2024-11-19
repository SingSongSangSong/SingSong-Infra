variable "vpc_id" {
  description = "The VPC ID where the bastion host will be deployed"
  type        = string
}

variable "public_subnet1_id" {
  description = "The ID of the public subnet for the bastion host"
  type        = string
}

variable "ec2_key_name" {
  description = "The name of the key pair for the bastion host"
  type        = string
}

variable "ec2_public_key" {
  description = "The public key for the key pair used to access the bastion host"
  type        = string
}

variable "ec2_private_key" {
  description = "The path to the private key file for SSH access to the bastion host"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type for the bastion host"
  type        = string
  default     = "c6g.xlarge" # Default instance type
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the bastion host"
  type        = list(string)
  default     = ["0.0.0.0/16"] # Default to allow all access
}

variable "bastion_host_name" {
  description = "Name tag for the bastion host instance"
  type        = string
  default     = "bastion-host"
}