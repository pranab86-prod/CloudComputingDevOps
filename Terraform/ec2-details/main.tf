provider "aws" {
  region = "us-west-2"
}

# -------------------------
# VPC
# -------------------------
resource "aws_vpc" "prodvpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "my-vpc"
  }
}

# -------------------------
# Subnet
# -------------------------
resource "aws_subnet" "prodsubnet" {
  vpc_id                  = aws_vpc.prodvpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "my-subnet"
  }
}

# -------------------------
# Internet Gateway
# -------------------------
resource "aws_internet_gateway" "prodigw" {
  vpc_id = aws_vpc.prodvpc.id

  tags = {
    Name = "my-igw"
  }
}

# -------------------------
# Route Table
# -------------------------
resource "aws_route_table" "prodroutetable" {
  vpc_id = aws_vpc.prodvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prodigw.id
  }

  tags = {
    Name = "my-route-table"
  }
}

# Associate Route Table with Subnet
resource "aws_route_table_association" "prod_rta" {
  subnet_id      = aws_subnet.prodsubnet.id
  route_table_id = aws_route_table.prodroutetable.id
}

# -------------------------
# Security Group
# -------------------------
resource "aws_security_group" "prod_sg" {
  vpc_id = aws_vpc.prodvpc.id
  name   = "allow-ssh-http"

  # Allow SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow All Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-sg"
  }
}

# -------------------------
# Key Pair
# -------------------------
resource "aws_key_pair" "prod_key" {
  key_name   = "my-ec2-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# -------------------------
# EC2 Instances (6 count)
# -------------------------
resource "aws_instance" "my_ec2" {
  count         = 6
  ami           = "ami-03aa99ddf5498ceb9" # Ubuntu 22.04 us-west-2
  instance_type = "t3.medium"
  subnet_id     = aws_subnet.prodsubnet.id
  key_name      = aws_key_pair.prod_key.key_name
  vpc_security_group_ids = [aws_security_group.prod_sg.id]

  tags = {
    Name = "my-ubuntu-ec2-${count.index + 1}"
  }
}
