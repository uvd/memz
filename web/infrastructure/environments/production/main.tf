terraform {
  backend "s3" {
    encrypt = true
    bucket  = "uvd-terraform-state"
    key     = "memz-web/production/terraform.tfstate"
    region  = "eu-west-1"
  }
}

module "main" {
  source = "../../memz"
  
  domain            = "memz.uvd.co.uk"
  environment = "production"
}
