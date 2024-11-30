resource "aws_default_security_group" "myapp-sg" {
  vpc_id = var.vpc_id

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
  public_key = file(var.public_key_location)
  
}

resource "aws_instance" "myapp-ec2" {
  ami = data.aws_ami.amz-linux-image.id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_default_security_group.myapp-sg.id]
  availability_zone = var.av_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.myapp-sshkey.key_name
  user_data = file("entry-script.sh")

  tags = {
    Name = "${var.env-prefix}-ec2"
  }
}
