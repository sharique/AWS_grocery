terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# Find latest linux Ami
data "aws_ami" "latest_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Setup EC2 instance
resource "aws_instance" "web_app" {
  tags = {
    Name : "web_app"
  }
  ami                    = data.aws_ami.latest_linux.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_app_sg.id]
}

# Configure VPC
resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tf_vpc"
  }
}

# Web app security group
resource "aws_security_group" "web_app_sg" {
  name        = "web_app_sg"
  description = "Allow http traffic"
  vpc_id      = aws_vpc.tf_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "web_app_sg"
  }
}

resource "aws_db_instance" "postgres_db" {
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  engine_version    = "17.4"
  allocated_storage = 20

  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow connection between RDS and EC2"
  vpc_id      = aws_vpc.tf_vpc.id
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    # IMPORTANT: Only allow traffic from the EC2's Security Group
    security_groups = [aws_security_group.web_app_sg.id]
  }
  tags = {
    name = "rds_sg"
  }
}
