
resource "aws_db_instance" "postgres_db" {
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  engine_version    = "18.0"
  allocated_storage = 20
  db_name           = "grocery_db"
  identifier        = "web-app-db"

  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = var.subnet_group_name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  storage_encrypted       = true
  backup_retention_period = 7
  tags = {
    Name = "web_app_db"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "Allow connection between RDS and EC2"
  vpc_id      = var.vpc_id
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    # IMPORTANT: Only allow traffic from the EC2's Security Group
    security_groups = [var.web_app_sg_id]
  }
  tags = {
    name = "rds_sg"
  }
}

resource "aws_db_instance" "postgres_db_replica" {
  identifier          = "web-app-db-replica"
  instance_class      = "db.t3.micro"
  replicate_source_db = aws_db_instance.postgres_db.identifier
  publicly_accessible = false
  storage_encrypted   = true
  skip_final_snapshot = true
  tags = {
    Name = "web_app_db_replica"
  }
  availability_zone      = "eu-central-1b"
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}
