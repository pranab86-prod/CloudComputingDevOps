provider "aws" {
  region = "us-west-2" # change as per your requirement
}

# -------------------------------
# VPC
# -------------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "prodvpc"
  }
}

# -------------------------------
# Subnets (example 4 subnets)
# -------------------------------
resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "prodsub1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "prodsub2"
  }
}

resource "aws_subnet" "subnet3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2c"

  tags = {
    Name = "prodsub3"
  }
}

resource "aws_subnet" "subnet4" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-west-2d"

  tags = {
    Name = "prodsub4"
  }
}

# -------------------------------
# Internet Gateway
# -------------------------------
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "my-igw"
  }
}

# -------------------------------
# Route Tables
# -------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Associate public subnets
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.public_rt.id
}

# Private route tables (separate for each AZ for HA)
resource "aws_route_table" "private_rt1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt1"
  }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.subnet3.id
  route_table_id = aws_route_table.private_rt1.id
}

resource "aws_route_table" "private_rt2" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-rt2"
  }
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.subnet4.id
  route_table_id = aws_route_table.private_rt2.id
}

# -------------------------------
# S3 VPC Endpoint (Gateway)
# -------------------------------
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-west-2.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private_rt1.id,
    aws_route_table.private_rt2.id
  ]

  tags = {
    Name = "s3-endpoint"
  }
}
