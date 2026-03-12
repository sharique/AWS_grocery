output "endpoint" {
  value = aws_db_instance.postgres_db.address
}

output "port" {
  value = aws_db_instance.postgres_db.port
}
