variable "DB_USERNAME" {
  description = "The username for the master DB user"
  type        = string
  default     = "admin"
}

variable "DB_PASSWORD" {
  description = "The password for the master DB user"
  type        = string
  default     = "password"
}

variable "CERTIFICATE_URL" {
  type    = string
  default = ""
}

variable "PRIVATE_KEY_URL" {
  type    = string
  default = ""
}

variable "VPC_NAME" {
  type    = string
  default = ""
}

variable "ECR_REPOSITORY_NAME" {
    type    = string
    default = ""
}

variable "ECR_REPOSITORY_URL" {
    type    = string
    default = ""
}

variable "TARGET_GROUPS_URL" {
  type    = string
  default = ""
}

variable "SECURITY_RULES_URL" {
  type    = string
  default = ""
}