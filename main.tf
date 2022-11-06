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

variable "subnet-cidr-block" {
  description = "subnet-cidr"
}
variable "vpc-cidr-block" {
  description = "vpc-cidr"
}

resource "aws_vpc" "development-vpc" {
  cidr_block = var.vpc-cidr-block
  tags = {
    Name: "development"
    Terraform: "true"
  }
}

resource "aws_subnet" "dev-subnet" {
  vpc_id     = aws_vpc.development-vpc.id
  cidr_block = var.subnet-cidr-block
  availability_zone = "us-east-1b"
  tags = {
    Name: "subnet-dev-net"
    Terraform: "true"
  }
  }

  output "my-vpc-id" {
    value = aws_vpc.development-vpc.id
    
  }
  
  output "my-subnet-id" {
    value = aws_subnet.dev-subnet.id
  }



