# GroceryMate Infrastructure

Terraform configuration for GroceryMate on AWS (`eu-central-1`). The root module orchestrates four child modules.

## Modules

| Module | Path | Resources |
|---|---|---|
| networking | `./networking` | VPC, public/private subnets (2 AZs), IGW, route tables, DB subnet group |
| compute | `./compute` | EC2 t3.micro (Amazon Linux 2023), security group, IAM role + instance profile |
| database | `./database` | RDS PostgreSQL 18.0 (primary + read replica in eu-central-1b), security group |
| avatars | `./avatars` | S3 bucket for user avatar storage |

## Remote State

State is stored in S3 with file-based locking:

| Setting | Value |
|---|---|
| Bucket | `saf-tf-store-states` |
| Region | `eu-central-1` |
| Key | `terraform.tfstate` |
| Encryption | enabled |

## Required Variables (`variables.tfvars`)

| Variable | Sensitive | Description |
|---|---|---|
| `db_username` | no | RDS master username |
| `db_password` | yes | RDS master password |
| `jwt_secret_key` | yes | Flask JWT signing secret |

## SSM Parameter Store

Terraform writes secrets to SSM at apply time. The EC2 instance reads them at boot via its IAM role — no secrets are stored in `.env` files or the Docker image.

| Parameter | Type |
|---|---|
| `/grocerymate/db_username` | String |
| `/grocerymate/db_password` | SecureString |
| `/grocerymate/jwt_secret_key` | SecureString |
| `/grocerymate/rds_endpoint` | String |

## EC2 IAM Permissions

The instance profile grants the EC2 instance permission to:

- Read SSM parameters under `/grocerymate/*`
- Pull images from ECR repository `masterschool` (`eu-central-1`)

## Outputs

| Output | Description |
|---|---|
| `ec2_public_ip` | Public IP of the web app EC2 instance |
| `rds_endpoint` | RDS PostgreSQL primary endpoint |
| `avatars_arn` | ARN of the avatars S3 bucket |

## Usage

```sh
cd infrastructure
terraform init
terraform plan -var-file=variables.tfvars
terraform apply -var-file=variables.tfvars
terraform destroy -var-file=variables.tfvars
```
