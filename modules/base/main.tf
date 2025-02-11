## VPC 를 만든다 (Subnet: Private1, Private2, Public1, Public2)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name = "singsong-vpc"
  cidr = "10.0.0.0/16"

  azs = ["ap-northeast-2a", "ap-northeast-2b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = false

  tags = {
    Terraform = "true"
    Environment = "Test"
  }
}

## ECR을 만든다.
resource "aws_ecr_repository" "singsong-ecr" {
  name                 = "singsong-golang-private"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Terraform   = "true"
    Environment = "Test"
  }
}

# ## ALB Listener에 사용할 Self-Signed Certificate를 만든다
resource "aws_iam_server_certificate" "self_signed_cert" {
  name_prefix   = "test-cert"
  certificate_body = file(var.CERTIFICATE_URL)
  private_key      = file(var.PRIVATE_KEY_URL)
}
