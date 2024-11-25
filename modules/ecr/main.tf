resource "aws_ecr_repository" "repositories" {
  for_each = toset(var.ECR_REPOSITORY_NAME)

  name                 = each.value
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}