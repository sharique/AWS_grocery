variable "vpc_id" {
  type        = string
  description = "VPC to place security group in"
}

variable "subnet_id" {
  type        = string
  description = "Subnet for EC2 instance"
}
