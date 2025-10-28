terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

# ---------
# Variables (quick inline)
# ---------
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "public_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "private_cidrs" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}
variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}
variable "desired_capacity" { default = 2 }
variable "min_size" { default = 1 }
variable "max_size" { default = 3 }

# ---------
# Data: Latest Ubuntu AMI (canonical)
# ---------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["03aa99ddf5498ceb9"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# ---------
# VPC + Subnets
# ---------
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "tf-prod-vpc" }
}

# Public subnets (2 AZs)
resource "aws_subnet" "public" {
  for_each = { for i, az in var.azs : az => i }
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_cidrs[each.value]
  availability_zone = each.key
  map_public_ip_on_launch = true

  tags = { Name = "tf-public-${each.key}" }
}

# Private subnets (2 AZs)
resource "aws_subnet" "private" {
  for_each = { for i, az in var.azs : az => i }
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_cidrs[each.value]
  availability_zone = each.key
  map_public_ip_on_launch = false

  tags = { Name = "tf-private-${each.key}" }
}

# ---------
# Internet Gateway + Public route table
# ---------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "tf-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "tf-public-rt" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate public subnets with public RT
resource "aws_route_table_association" "public_rta" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# ---------
# NAT Gateway (in first public subnet) for private -> internet
# ---------
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = { Name = "tf-nat-eip" }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[var.azs[0]].id
  tags = { Name = "tf-natgw" }
  depends_on = [aws_internet_gateway.igw]
}

# Private route table (use NAT)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "tf-private-rt" }
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Associate private subnets with private RT
resource "aws_route_table_association" "private_rta" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# ---------
# Security Groups
# ---------

# ALB SG - allow HTTP/HTTPS from internet
resource "aws_security_group" "alb_sg" {
  name        = "sg-alb"
  description = "Allow HTTP/HTTPS from internet"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sg-alb" }
}

# App SG - allow HTTP only from ALB and SSH from admin CIDR (optional)
resource "aws_security_group" "app_sg" {
  name        = "sg-app"
  description = "Allow traffic from ALB + optional SSH"
  vpc_id      = aws_vpc.this.id

  # Allow HTTP from ALB SG
  ingress {
    description      = "Allow HTTP from ALB"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  # Optional: allow SSH from your IP (change to your IP)
  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # <--- change to your IP for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sg-app" }
}

# ---------
# Key Pair (optional; requires ~/.ssh/id_rsa.pub present)
# ---------
resource "aws_key_pair" "this" {
  key_name   = "tf-key"
  public_key = fileexists("~/.ssh/id_rsa.pub") ? file("~/.ssh/id_rsa.pub") : "" 
  # If empty, AWS will error — replace with your public key or remove key_name usage below
}

# ---------
# Launch Template (no subnet so ASG will select subnets). Instances in private subnets.
# ---------
resource "aws_launch_template" "app" {
  name_prefix   = "tf-app-lt-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.this.key_name != "" ? aws_key_pair.this.key_name : null

  # Do NOT set subnet_id here so ASG can launch into vpc_zone_identifier subnets
  network_interfaces {
    security_groups             = [aws_security_group.app_sg.id]
    associate_public_ip_address = false
  }

  iam_instance_profile {
    # optional: define instance profile if you need e.g., SSM access
    # name = aws_iam_instance_profile.my_profile.name
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y apache2
              systemctl enable apache2
              systemctl start apache2
              echo "<h1>Hello from ASG instance</h1>" > /var/www/html/index.html
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "tf-app-instance"
    }
  }
}

# ---------
# ALB + Target Group + Listener
# ---------
resource "aws_lb" "app_alb" {
  name               = "tf-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for s in aws_subnet.public : s.id]

  tags = { Name = "tf-app-alb" }
}

resource "aws_lb_target_group" "app_tg" {
  name        = "tf-app-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "instance"

  health_check {
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = { Name = "tf-app-tg" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# ---------
# Auto Scaling Group using Launch Template
# ---------
resource "aws_autoscaling_group" "app_asg" {
  name_prefix        = "tf-app-asg-"
  desired_capacity   = var.desired_capacity
  min_size           = var.min_size
  max_size           = var.max_size
  vpc_zone_identifier = [for s in aws_subnet.private : s.id]  # place instances in private subnets

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  health_check_type         = "ELB"
  health_check_grace_period = 120

  target_group_arns = [aws_lb_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = "tf-app-asg-instance"
    propagate_at_launch = true
  }
}

# Optional: scale-in protection, policies, lifecycle hooks can be added.

# ---------
# Outputs
# ---------
output "alb_dns" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.app_alb.dns_name
}

output "asg_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.app_asg.name
}

output "public_subnets" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnets" {
  value = [for s in aws_subnet.private : s.id]
}

output "target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}
