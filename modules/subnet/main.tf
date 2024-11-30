resource "aws_subnet" "myapp-subnet" {
  vpc_id     = var.vpc_id
  cidr_block = var.myapp-cidr-subnet
  availability_zone = var.av_zone
  tags = {
    Name: "${var.env-prefix}-subnet"
  }
}


resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.env-prefix}-igw"
  }
}

resource "aws_default_route_table" "myapp-route-table" {
  default_route_table_id = var.default_route_table_id

  route{
    cidr_block = var.myapp-cidr-rtb
    gateway_id = aws_internet_gateway.myapp-igw.id
  }

  tags = {
  Name: "${var.env-prefix}-rtb"
}
}

