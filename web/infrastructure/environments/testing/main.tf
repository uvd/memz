terraform {
  backend "s3" {
    encrypt = true
    bucket  = "uvd-terraform-state"
    key     = "memz-web/testing/terraform.tfstate"
    region  = "eu-west-1"
  }
}

module "main" {
  source = "../../memz"

  domain            = "testing.memz.uvd.co.uk"
  environment = "production"
}
