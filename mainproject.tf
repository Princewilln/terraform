terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.37.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "myapp-cidr-vpc" {}
variable "env-prefix" {}
variable "myapp-cidr-subnet" {}
variable "av_zone" {}
variable "myapp-cidr-rtb" {}
variable "myapp-cidr-ingress" {}
variable "instance_type" {}
variable "public_key_location" {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.myapp-cidr-vpc
  tags = {
    Name: "${var.env-prefix}-vpc"
  }

}
resource "aws_subnet" "myapp-subnet" {
  vpc_id     = aws_vpc.myapp-vpc.id
  cidr_block = var.myapp-cidr-subnet
  availability_zone = var.av_zone
  tags = {
    Name: "${var.env-prefix}-subnet"
  }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id

  tags = {
    Name = "${var.env-prefix}-igw"
  }
}

resource "aws_default_route_table" "myapp-route-table" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

  route{
    cidr_block = var.myapp-cidr-rtb
    gateway_id = aws_internet_gateway.myapp-igw.id
  }

  tags = {
  Name: "${var.env-prefix}-rtb"
}
}

resource "aws_default_security_group" "myapp-sg" {
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidr_blocks = [ var.myapp-cidr-ingress ]
  }

   ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
   tags = {
  Name: "${var.env-prefix}-sg"
}
}
data "aws_ami" "amz-linux-image" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

}
resource "aws_key_pair" "myapp-sshkey" {
  key_name = "myapp-key"
  public_key = var.public_key_location
  
}

resource "aws_instance" "myapp-ec2" {
  ami = data.aws_ami.amz-linux-image.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.myapp-subnet.id
  vpc_security_group_ids = [aws_default_security_group.myapp-sg.id]
  availability_zone = var.av_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.myapp-sshkey.key_name
  user_data = file("entry-script.sh")

  tags = {
    Name = "${var.env-prefix}-ec2"
  }
}
output "instance_ip_addr" {
  value = aws_instance.myapp-ec2
}
