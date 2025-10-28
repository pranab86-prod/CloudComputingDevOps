provider "aws" {
  region = var.region
}

# Get latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "app_template" {
  name_prefix   = "app-launch-template-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "Hello from AutoScaling EC2" > /usr/share/nginx/html/index.html
            EOF
  )
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "app-asg"
  desired_capacity          = 2
  min_size                  = 2
  max_size                  = 2
  vpc_zone_identifier       = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }
  health_check_type         = "EC2"
  health_check_grace_period = 30
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "asg-ec2"
    propagate_at_launch = true
  }
}

# Create VPC, Subnets, Internet Gateway, Route Table
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = "asg-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b"]
  public_subnets  = ["10.0.112.0/24", "10.0.122.0/24"]
  enable_nat_gateway = false
  single_nat_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = "10.0.112.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = "10.0.122.0/24"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
}
