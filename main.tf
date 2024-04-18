provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = ""
    key            = "terraform-lambda--config-update"
    region         = "eu-central-1"
    encrypt        = true
  }
}
