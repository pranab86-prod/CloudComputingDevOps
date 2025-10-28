variable "region" {
  default = "us-west-2"
}

variable "instance_type" {
  default = "t2.medium"
}

variable "key_name" {
  description = "Name of the existing EC2 key pair"
  type        = string
}
