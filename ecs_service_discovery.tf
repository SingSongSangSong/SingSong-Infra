// Cloud Map 네임스페이스 생성 (기존 Hosted Zone 이름과 연동)
resource "aws_service_discovery_private_dns_namespace" "singsong_ecs_service_discovery_namespace" {
  name  = var.route53_zone_name  // 기존 Route 53 Hosted Zone 이름을 사용
  vpc   = aws_vpc.singsong_vpc.id
}

// SingSong-Golang 서비스 디스커버리
resource "aws_service_discovery_service" "singsong_ecs_service_golang_discovery" {
  name  = "golang"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.singsong_ecs_service_discovery_namespace.id  # Cloud Map 네임스페이스 ID 사용
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

// SingSong-Embedding 서비스 디스커버리
resource "aws_service_discovery_service" "singsong_ecs_service_embedding_discovery" {
  name  = "embedding"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.singsong_ecs_service_discovery_namespace.id  # Cloud Map 네임스페이스 ID 사용
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

// Milvus, Attu 서비스 디스커버리
resource "aws_service_discovery_service" "singsong_ecs_service_milvus_discovery" {
  name  = "milvus"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.singsong_ecs_service_discovery_namespace.id  # Cloud Map 네임스페이스 ID 사용
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

