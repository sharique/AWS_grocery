terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }
  backend "s3" {
    bucket       = "saf-tf-store-states"
    key          = "terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "eu-central-1"
}

module "networking" {
  source = "./networking"
}

module "compute" {
  source = "./compute"

  subnet_id = module.networking.subnet_public_a_id
  vpc_id    = module.networking.vpc_id
}

module "database" {
  source = "./database"

  vpc_id            = module.networking.vpc_id
  subnet_group_name = module.networking.db_subnet_group_name
  web_app_sg_id     = module.compute.web_app_sg_id
  db_username       = var.db_username
  db_password       = var.db_password
}
# S3 bucket for storign avatars.
module "avatars" {
  source = "./avatars"
}
