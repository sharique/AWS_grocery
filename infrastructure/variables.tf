variable "db_username" {
  type      = string
  sensitive = false
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "jwt_secret_key" {
  type      = string
  sensitive = true
}
