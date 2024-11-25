variable "security_group_name" {
  description = "Name of the Security Group"
  type        = string
}

variable "security_group_vpc_id" {
  description = "VPC ID to associate with the Security Group (e.g., vpc-xxxxxx)"
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [{
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }]
}

variable "tags" {
  description = "Tags to apply to the Security Group"
  type        = map(string)
  default     = {}
}