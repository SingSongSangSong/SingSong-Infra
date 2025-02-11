run "execute" {
  command = plan
  module {
      source = "./"
  }
  assert {
    condition = length(module.base.public_subnets) == 2
    error_message = "wrong length of public subnets"
  }
}