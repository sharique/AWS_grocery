# Configure VPC
resource "aws_vpc" "tf_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "tf_vpc"
  }
}

# Subnets in two AZs (required for RDS subnet group)
resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "public_a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "public_b"
  }
}


# Internet gateway for EC2 public access
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "tf_igw"
  }
}

# Route table for public subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.tf_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_rt"
  }
}


resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# Private subnets for RDS (no route to IGW)
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "private_a"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.tf_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-central-1b"
  tags = {
    Name = "private_b"
  }
}

# Private route table — intentionally has no route to IGW
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.tf_vpc.id
  tags = {
    Name = "private_rt"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}

# DB subnet group for RDS (private subnets, 2 AZs required)
resource "aws_db_subnet_group" "postgres_subnet_group" {
  name       = "postgres_subnet_group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  tags = {
    Name = "postgres_subnet_group"
  }
}
