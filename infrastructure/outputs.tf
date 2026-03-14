output "ec2_public_ip" {
  description = "Public IP of the web app EC2 instance"
  value       = module.compute.public_ip
}
output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.database.endpoint
}
output "avatars_arn" {
  description = "ARN of Avatar S3 bucket"
  value       = module.avatars.avatar_arn
}
