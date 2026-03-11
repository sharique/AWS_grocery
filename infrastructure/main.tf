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
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.web_app_sg.id]
}

# Configure VPC
resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tf_vpc"
  }
}

# Subnets in two AZs (required for RDS subnet group)
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "public_a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "public_b"
  }
}

# Internet gateway for EC2 public access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "tf_igw"
  }
}

# Route table for public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.tf_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# DB subnet group for RDS (requires 2+ AZs)
resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "postgres_subnet_group"
  subnet_ids = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  tags = {
    Name = "postgres_subnet_group"
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
  db_name           = "grocery_db"
  identifier        = "web-app-db"

  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.postgres_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  publicly_accessible    = false
  tags = {
    Name = "web_app_db"
  }
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

# S3 bucket for storign avatars.
module "avatar_s3" {
  source = "./avatar"
}
