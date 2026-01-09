provider "aws" {
  region = var.region
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
  key_name   = var.key_name
  public_key = tls_private_key.access_key.public_key_openssh
}

resource "aws_security_group" "wordpress_sg" {
  name        = "wordpress_sg"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_access_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.web_access_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "wordpress" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.wordpress_sg.id]

  user_data = file("${path.module}/install_wordpress.sh")

  tags = {
    Name = "WordpressInstanceWithVariables"
  }
}
