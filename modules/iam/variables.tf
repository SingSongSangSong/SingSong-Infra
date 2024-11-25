variable "role_name" {
  description = "Name of the IAM Role for ECS Task Execution"
  type        = string
}

variable "policy_document" {
  description = "IAM policy document for ECS Task Execution"
  type        = any
}