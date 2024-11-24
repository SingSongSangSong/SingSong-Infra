// 기존의 Route53 가져오기
data "aws_route53_zone" "singsong_dns" {
  name = var.existing_route53_zone_name
}

data "aws_acm_certificate" "singsong_cert" {
  domain = var.certificate_domain
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

# // Route 53 CNAME 레코드 생성
# resource "aws_route53_record" "singsong_cname_record" {
#   zone_id = data.aws_route53_zone.singsong_dns.zone_id
#   name    = var.certificate_domain
#   type    = "CNAME"
#   ttl     = 300
#   records = [aws_lb.singsong_load_balancer.dns_name]
# }

data "aws_route53_zone" "singsong_bastion_dns" {
  name = var.BASTION_ZONE_NAME
}

data "aws_acm_certificate" "singsong_bastion_cert" {
  domain = var.BASTION_CERTIFICATE_DOMAIN
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

# // Route 53 CNAME 레코드 생성
# resource "aws_route53_record" "singsong_bastion_cname_record" {
#   zone_id = data.aws_route53_zone.singsong_bastion_dns.zone_id
#   name    = var.BASTION_CERTIFICATE_DOMAIN
#   type    = "CNAME"
#   ttl     = 300
#   records = [aws_lb.singsong_bastion_load_balancer.dns_name]
# }