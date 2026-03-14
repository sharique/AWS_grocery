
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
  ami                         = data.aws_ami.latest_linux.id
  instance_type               = "t3.micro"
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.web_app_sg.id]
  user_data                   = file("${path.module}/user_data.sh")
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

}

resource "aws_iam_role" "ec2_role" {
  name               = "ec2_web_app_role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume.json
}

data "aws_iam_policy_document" "ec2_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "ssm_read" {
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ssm:GetParameter", "ssm:GetParameters"]
      Resource = "arn:aws:ssm:eu-central-1:*:parameter/grocerymate/*"
      },
      { Effect = "Allow", Action = ["ecr:GetAuthorizationToken"], Resource = "*" },
      { Effect = "Allow",
        Action = ["ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer"],
      Resource = "arn:aws:ecr:eu-central-1:*:repository/masterschool" }

    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_web_app_profile"
  role = aws_iam_role.ec2_role.name
}

