
# Web app security group
resource "aws_security_group" "web_app_sg" {
  name        = "web_app_sg"
  description = "Allow http traffic"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "web_app_sg"
  }
}

# Find latest linux Ami
data "aws_ami" "latest_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Setup EC2 instance
resource "aws_instance" "web_app" {
  tags = {
    Name : "web_app"
  }
  ami                    = data.aws_ami.latest_linux.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.web_app_sg.id]
  user_data              = file("${path.module}/user_data.sh")
}
