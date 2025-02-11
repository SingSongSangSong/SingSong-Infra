output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "signed_cert_arn" {
  value = aws_iam_server_certificate.self_signed_cert.arn
}

output "ecr_repository_url" {
  value = aws_ecr_repository.singsong-ecr.repository_url
}

output "ecr_repository_name" {
  value = split("/", aws_ecr_repository.singsong-ecr.repository_url)[1]
}

