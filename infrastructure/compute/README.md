# Compute Module

This module provisions the EC2 instance that runs the Dockerized GroceryMate application, along with the IAM role and security group it needs to operate securely.

## Resources

1. **EC2 Instance** - A `t3.micro` instance running Amazon Linux 2023 in the public subnet:
    - Automatically pulls the latest AMI matching `al2023-ami-2023.*`
    - Runs a `user_data.sh` bootstrap script on first boot (pulls image from ECR, reads secrets from SSM, starts the container)
    - Has a public IP assigned for direct internet access

2. **Web App Security Group** - Controls inbound and outbound traffic for the EC2 instance:
    - Allows inbound HTTP traffic on port `80` from anywhere
    - Allows all outbound traffic

3. **IAM Role** (`ec2_web_app_role`) - Grants the EC2 instance permissions to interact with AWS services without static credentials:
    - **SSM** — read-only access to all parameters under `/grocerymate/*`
    - **ECR** — authenticate to ECR and pull images from the `masterschool` repository

4. **IAM Instance Profile** - Attaches the IAM role to the EC2 instance so it can assume the role automatically.

## Variables

| Variable | Description |
|---|---|
| `vpc_id` | VPC to create the security group in (from networking module) |
| `subnet_id` | Subnet to launch the EC2 instance into (from networking module) |

## Outputs

| Output | Description |
|---|---|
| `instance_id` | EC2 instance ID |
| `public_ip` | Public IP address of the EC2 instance |
| `web_app_sg_id` | Security group ID (passed to the database module) |
