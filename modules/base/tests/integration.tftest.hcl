run "plan_test" {
  module {
    source = "./"
  }
  command = plan

  variables {
    CERTIFICATE_URL = "/Users/sunwupark/Documents/SingSong-Infra/json/certificate/certificate.crt"
    PRIVATE_KEY_URL = "/Users/sunwupark/Documents/SingSong-Infra/json/certificate/private.key"
    VPC_NAME = "singsong-vpc"
  }

  assert {
    condition     = length(module.vpc.public_subnets) == 2
    error_message = "wrong length of public subnets"
  }

  assert {
      condition     = length(module.vpc.private_subnets) == 2
      error_message = "wrong length of private subnets"
  }

  assert {
      condition     = length(module.vpc.azs) == 2
      error_message = "wrong length of azs"
  }
}

run "plan_apply" {
  command = apply
  module {
      source = "./"
  }

  variables {
      CERTIFICATE_URL = "/Users/sunwupark/Documents/SingSong-Infra/json/certificate/certificate.crt"
      PRIVATE_KEY_URL = "/Users/sunwupark/Documents/SingSong-Infra/json/certificate/private.key"
      VPC_NAME = "singsong-vpc"
  }

  assert {
    condition     = module.vpc.name == "singsong-vpc"
    error_message = "wrong name of vpc"
  }

  assert {
    condition = split("/", aws_ecr_repository.singsong-ecr.repository_url)[1] == "singsong-golang-private"
    error_message = "wrong name of ecr"
  }
}

