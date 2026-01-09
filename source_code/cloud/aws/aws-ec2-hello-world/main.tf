terraform {
}

provider "aws" {
  region = "eu-central-1"
}


resource "tls_private_key" "access_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "private_key" {
  value     = tls_private_key.access_key.private_key_pem
  sensitive = true
}

resource "aws_key_pair" "deployer" {
  key_name   = "ec2-deployer-key"
  public_key = tls_private_key.access_key.public_key_openssh
}

resource "aws_security_group" "hello_world_sg" {
  name        = "hello_world_sg"
  description = "Allow SSH and HTTP"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "hello_world" {
  ami                    = "ami-03cceb19496c25679"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  security_groups        = [aws_security_group.hello_world_sg.name]

  user_data = file("${path.module}/install_wordpress.sh")

  tags = {
    Name = "HelloWorldInstance"
  }
}
