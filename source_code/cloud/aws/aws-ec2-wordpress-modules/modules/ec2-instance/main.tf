resource "aws_instance" "hello_world" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = var.security_group_ids

  user_data = file("${path.module}/install_wordpress.sh")

  tags = {
    Name = "WordpressInstanceWithModules"
  }
}
