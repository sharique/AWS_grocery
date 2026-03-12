terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }
  backend "s3" {
    bucket       = "saf-tf-states"
    key          = "terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = "eu-central-1"
}

module "netowrking" {
  source = "./networking"
}

module "compute" {
  source = "./compute"

  subnet_id = module.netowrking.subnet_public_a_id
  vpc_id    = module.netowrking.vpc_id
}

module "database" {
  source = "./database"

  vpc_id            = module.netowrking.vpc_id
  subnet_group_name = module.netowrking.db_subnet_group_name
  web_app_sg_id     = module.compute.web_app_sg_id
  db_username       = var.db_username
  db_password       = var.db_password
}
# S3 bucket for storign avatars.
module "avatar_s3" {
  source = "./avatar"
}
