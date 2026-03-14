# SSM Parameter Store — application secrets and config
#
# Parameters are written once by Terraform. The EC2 instance (or any code
# with the right IAM permissions) reads them at runtime so secrets never
# have to be stored in .env files or baked into the Docker image.

resource "aws_ssm_parameter" "db_username" {
  name  = "/grocerymate/db_username"
  type  = "String"
  value = var.db_username

  tags = { Name = "grocerymate-db-username" }
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/grocerymate/db_password"
  type  = "SecureString" # encrypted with AWS-managed KMS key
  value = var.db_password

  tags = { Name = "grocerymate-db-password" }
}

resource "aws_ssm_parameter" "jwt_secret_key" {
  name  = "/grocerymate/jwt_secret_key"
  type  = "SecureString"
  value = var.jwt_secret_key

  tags = { Name = "grocerymate-jwt-secret-key" }
}

resource "aws_ssm_parameter" "rds_endpoint" {
  name  = "/grocerymate/rds_endpoint"
  type  = "String"
  value = module.database.endpoint # resolved after terraform apply

  tags = { Name = "grocerymate-rds-endpoint" }
}
