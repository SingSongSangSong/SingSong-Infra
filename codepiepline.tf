resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "codepipeline-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ecr:*",
            "ecs:*",
            "iam:PassRole",
            "s3:*",
            "codebuild:*",
            "codedeploy:*"
          ]
          Resource = "*"
        }
      ]
    })
  }
}

resource "aws_codepipeline" "codepipeline" {
  name     = "singsong-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline_bucket.bucket
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        S3Bucket = aws_s3_bucket.codepipeline_bucket.bucket
        S3ObjectKey = "source.zip"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_project.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ECS"
      version          = "1"
      input_artifacts  = ["build_output"]

      configuration = {
        ClusterName = aws_ecs_cluster.singsong_ecs_cluster.name
        ServiceName = aws_ecs_service.singsong_ecs_service.name
        FileName    = "imagedefinitions.json"
      }
    }
  }
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "singsongsangsong-codepipeline-bucket"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = "singsongsangsong-codebuild"
  service_role  = aws_iam_role.codebuild_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
  }
  source {
    type     = "CODEPIPELINE"
    buildspec = <<EOF
version: 0.2
phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - docker build -t $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${aws_ecr_repository.singsong_golang_ecr_repository.name}:latest .
      - docker tag $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${aws_ecr_repository.singsong_golang_ecr_repository.name}:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${aws_ecr_repository.singsong_golang_ecr_repository.name}:latest
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker image...
      - docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/${aws_ecr_repository.singsong_golang_ecr_repository.name}:latest
      - echo Writing image definitions file...
      - printf '[{"name":"container_name","imageUri":"%s.dkr.ecr.%s.amazonaws.com/%s:latest"}]' $AWS_ACCOUNT_ID $AWS_REGION ${aws_ecr_repository.singsong_golang_ecr_repository.name} > imagedefinitions.json
artifacts:
  files: imagedefinitions.json
EOF
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  inline_policy {
    name = "codebuild-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "ecr:*",
            "ecs:*",
            "s3:*",
            "logs:*"
          ]
          Resource = "*"
        }
      ]
    })
  }
}