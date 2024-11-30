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

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.myapp-cidr-vpc
  tags = {
    Name: "${var.env-prefix}-vpc"
  }
}

module "myapp-subnet" {
  source = "./modules/subnet"
  env-prefix = var.env-prefix
  myapp-cidr-subnet = var.myapp-cidr-subnet
  av_zone = var.av_zone
  vpc_id = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  myapp-cidr-rtb = var.myapp-cidr-rtb
  
}

module "myapp-ec2" {
  source = "./modules/webserver"
  env-prefix = var.env-prefix
  av_zone = var.av_zone
  myapp-cidr-ingress = var.myapp-cidr-ingress
  instance_type = var.instance_type
  public_key_location = var.public_key_location
  vpc_id = aws_vpc.myapp-vpc.id
  subnet_id = module.myapp-subnet.subnet.id  
}

