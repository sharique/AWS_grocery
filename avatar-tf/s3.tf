terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=6.0"
    }
  }
  backend "s3" {
    bucket       = "saf-tf-states"
    key          = "avatars/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true

  }
}

resource "aws_s3_bucket" "grocerymate-avatars" {
  bucket = "saf-grocerymate-avatars"
  tags = {
    Name        = "grocerymate-avatars"
    Environment = "Dev"
  }
}
