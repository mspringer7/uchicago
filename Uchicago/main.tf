terraform {
  backend "s3" {
    bucket  = "terraform-uchicago"
    key     = "tfstate/uchicago.tfstate"
    encrypt = true
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

module "infra" {
  source = "./infra"
  createdBy   = var.tags["createdBy"]
  owner       = var.tags["owner"]
  clientName  = var.tags["clientName"]
  product     = var.tags["product"]
  environment = var.tags["environment"]
}
