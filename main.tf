terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "swm_sunwupark"
    workspaces {
      name = "singsong-state-project"
    }
  }
}

provider "aws" {
  region = var.region
}