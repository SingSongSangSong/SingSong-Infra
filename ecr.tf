// ECR Repository 생성
resource "aws_ecr_repository" "singsong_golang_ecr_repository" {
  name = "singsong_golang_ecr_repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

// ECR for SingSongEmbedding
resource "aws_ecr_repository" "singsong_embedding_ecr_repository" {
  name = "singsong_embedding_ecr_repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}