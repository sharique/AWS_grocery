variable "vpc_id" {
  type        = string
  description = "VPC to place security group in"
}

variable "subnet_group_name" {
  type        = string
  description = "Subnet name for RDS instance (from networking)"
}

variable "web_app_sg_id" {
  type        = string
  description = "Security group of EC2 instace to connect to RDS"
}
variable "db_username" {
  type      = string
  sensitive = false
}

variable "db_password" {
  type      = string
  sensitive = true
}
