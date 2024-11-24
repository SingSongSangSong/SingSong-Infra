output "ECR_REPOSITORY_URL" {
    description = "ECR Repository URLs"
    value = { for name, repo in aws_ecr_repository.repositories : name => repo.repository_url }
}