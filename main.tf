provider "aws" {
  region = "us-east-1"
}

# Ubuntu 20.04
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Amazon Linux 2
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "ubuntu_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.instance_type

  vpc_security_group_ids = [aws_security_group.ubuntu_sg.id]

  tags = {
    Name = "Ubuntu_Instance"
  }

  user_data = local.ubuntu_user_data

}

resource "aws_instance" "amazon_linux_instance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = local.instance_type

  vpc_security_group_ids = [aws_security_group.amazon_linux_sg.id]

  tags = {
    Name = "AmazonLinux_Instance"
  }

  associate_public_ip_address = false #don't need because invoke inside vpc only

  user_data = local.amazon_linux_user_data

  depends_on = [
    aws_instance.ubuntu_instance,
    aws_security_group.ubuntu_sg
  ]

}

resource "aws_security_group" "ubuntu_sg" {
  name        = "ubuntu_security_group"
  description = "Allow inbound access for SSH, HTTP, HTTPS and ping; allow all outbound access"

  # inbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp" #to use command like "ping"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "amazon_linux_sg" {
  name        = "amazon_linux_security_group"
  description = "Allow inbound access for SSH, HTTP, HTTPS and ping within the local network only; no internet access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.ubuntu_instance.private_ip}/32"] # ubuntu private ip
    #cidr_blocks = ["172.31.0.0/16"] # local vpc network
    #/32 point on one IP address
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.ubuntu_instance.private_ip}/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.ubuntu_instance.private_ip}/32"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${aws_instance.ubuntu_instance.private_ip}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_instance.ubuntu_instance.private_ip}/32"]
  }
}