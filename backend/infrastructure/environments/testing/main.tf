terraform {
  backend "s3" {
    encrypt = true
    bucket  = "uvd-terraform-state"
    key     = "memz-backend/testing/terraform.tfstate"
    region  = "eu-west-1"
  }
}

module "main" {
  source = "../../memz"

  aws_region   = "eu-west-1"
  cluster_name = "uvd"

  domain            = "testing.api.memz.uvd.co.uk"
  container_version = "${var.container_version}"
  weave_cidr        = "10.32.119.0/24"

  environment = "testing"

  secret_key_base     = "${var.secret_key_base}"
  postgres_password   = "${var.postgres_password}"
  guardian_secret_key = "${var.guardian_secret_key}"

  repository_address = "${var.repository_address}"
}
