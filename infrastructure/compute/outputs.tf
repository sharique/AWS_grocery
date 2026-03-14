output "instance_id" {
  value = aws_instance.web_app.id
}

output "public_ip" {
  value = aws_instance.web_app.public_ip
}

output "web_app_sg_id" {
  value = aws_security_group.web_app_sg.id
}
