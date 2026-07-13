resource "aws_security_group" "sg_terraform" {
  name = "sg_terraform"
  description = "Security group for Terraform"
  vpc_id = var.vpc_id

  ingress{
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}