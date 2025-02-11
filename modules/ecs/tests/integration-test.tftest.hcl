run "plan_test" {
  command = apply
  module {
      source = "./"
  }

  variables {
    VPC_ID                      = "vpc-0c3d4490c68b1150c"
    VPC_PUBLIC_SUBNETS          = ["subnet-09212be8211b6c20c", "subnet-099e4fd4eb517f5c5"]
    SIGNED_CERT_ARN             = "arn:aws:acm:us-west-2:123456789012:certificate/abcd1234-efgh-5678-ijkl-90mnopqrstuv"
    capacity_providers_raw_url  = ""
    container_definitions_raw_url = ""
    ECR_REPOSITORY_URL          = "123456789012.dkr.ecr.us-west-2.amazonaws.com/singsong-golang-private"
    SECURITY_RULES_URL          = ""
    TARGET_GROUPS_URL           = ""
  }

}