output "vpc_id" {
  value = aws_vpc.tf_vpc.id
}

output "subnet_public_a_id" {
  value = aws_subnet.public_a.id
}

output "subnet_public_b_id" {
  value = aws_subnet.public_b.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.postgres_subnet_group.name
}
