variable "ECR_REPOSITORY_NAME" {
  description = "Names of the ECR Repositories"
  type        = list(string)
  default     = [] # 기본값 설정 (선택사항)
}