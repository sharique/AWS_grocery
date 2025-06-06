# mein provider und die Region Frankfurt auswählen
provider "aws" {
  region = "eu-central-1"
}

# SSH Key Pair generieren
 #resource "aws_key_pair" "my_ssh_key" {
  #key_name   = "thomasressel_terraform"  # Der Name des Schlüssels
  #public_key = file("thomasressel_terraform.ppk")  # Pfad zum öffentlichen SSH-Schlüssel
#}

resource "aws_instance" "ec2_instanz_terraform_thomasressel" {
  ami           = "ami-0ecf75a98fe8519d7"  # Amazon Linux 2
  instance_type = "t2.micro"
  key_name      = "thomasressel_terraform"
  vpc_security_group_ids = [
    aws_security_group.ssh_access.id,
    aws_security_group.web_access.id
  ]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
# Update system
yum update -y

# Install packages
sudo yum install -y git python3 python3-pip postgresql15 postgresql15-server postgresql15-contrib

# Clone your GitHub repo
cd /home/ec2-user
git clone https://github.com/Thomas-Ressel-92/AWS_grocery

# Set correct ownership
chown -R ec2-user:ec2-user /home/ec2-user/AWS_grocery

# Confirm tools
python3 --version
pip --version
psql --version
git --version

# === PostgreSQL Setup ===

# Start and Enable PostgreSQL
sudo /usr/bin/postgresql-setup --initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql

sudo systemctl status postgresql

sudo -i -u postgres psql -c "ALTER USER postgres WITH PASSWORD '12345';"

# Path to pg_hba.conf (default for local PostgreSQL)
PG_HBA="/var/lib/pgsql/data/pg_hba.conf"

# Backup first
sudo cp $PG_HBA ${PG_HBA}.bak

# Replace 'peer' or 'ident' with 'md5' for local connections
sudo sed -i -E 's/^(local\s+all\s+all\s+)(peer|ident)/\1md5/' $PG_HBA
sudo sed -i -E 's/^(host\s+all\s+all\s+127\.0\.0\.1\/32\s+)(peer|ident)/\1md5/' $PG_HBA
sudo sed -i -E 's/^(host\s+all\s+all\s+::1\/128\s+)(peer|ident)/\1md5/' $PG_HBA

# Restart PostgreSQL to apply changes
sudo systemctl restart postgresql

# Create DB, user, and grant access
cd /home/ec2-user
psql -U postgres -c "CREATE DATABASE grocerymate_db;"
psql -U postgres -c "CREATE USER grocery_user WITH ENCRYPTED PASSWORD '12345';"
psql -U postgres -c "ALTER USER grocery_user WITH SUPERUSER;"

# Then execute the file-based SQL
psql -U grocery_user -d grocerymate_db -f AWS_grocery/backend/app/sqlite_dump_clean.sql

# Run SELECTs to verify
psql -U grocery_user -d grocerymate_db -c "SELECT * FROM users;"
psql -U grocery_user -d grocerymate_db -c "SELECT * FROM products;"

# === Python Backend Setup ===

cd /home/ec2-user/AWS_grocery/backend
pip3 install -r requirements.txt

# Generate .env file and token
touch .env

# Generate secure key
python3 -c "import secrets; print(secrets.token_hex(32))"
EOF

  tags = {
    Name = "ec2_instanz_terraform_thomasressel"
  }
}

# Default-VPC
data "aws_vpc" "default" {
  default = true
}

# Security Group für SSH-Zugriff
resource "aws_security_group" "ssh_access" {
  name        = "allow_ssh_terraform"
  description = "SSHFromAnywhereAllowed"
  vpc_id      = data.aws_vpc.default.id  # Default-VPC verwenden

  # Eingehende Regel (inbound): SSH auf Port 22
  ingress {
    description = "SSHFromAnywhereAllow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # hier muss ich spaeter meine IP eingeben
  }

  # Ausgehende Regel (outbound): Alles erlaubt
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # -1 bedeutet: alle Protokolle
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group für RDS (PostgreSQL Port 5432)
resource "aws_security_group" "rds_sg" {
  name        = "rds_postgres_sg"
  description = "Allow PostgreSQL access from EC2"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ssh_access.id]  # erlaubt Zugriff von EC2 SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS PostgreSQL-Instance
resource "aws_db_instance" "terraform_rds_thomasressel" {
  identifier             = "db-resource-terraform-thomasressel" # This sets the actual RDS instance name
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "15.12"
  instance_class         = "db.t3.micro"
  db_name                = "db_virtual_terraform_thomasressel"
  username               = "postgres"
  password               = "postgres1234"  # In Produktion: Variable/Secret Manager
  parameter_group_name   = "default.postgres15"
  skip_final_snapshot    = true
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "db_resource_terraform_thomasressel_tag"
  }
}

resource "aws_security_group" "web_access" {
  name        = "web_access_sg"
  description = "Allow web access"
  vpc_id      = data.aws_vpc.default.id

  # Erlaube HTTP-Zugriff auf Port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Erlaube Zugriff auf Port 5000
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ausgehender Verkehr erlauben (Standard)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
