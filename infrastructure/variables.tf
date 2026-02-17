variable "db_username" {
  type      = string
  sensitive = false
}

variable "db_password" {
  type      = string
  sensitive = true
}
