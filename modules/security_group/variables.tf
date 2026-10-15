variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created."
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "Your trusted public IP in CIDR notation, for example 203.0.113.10/32"
  type        = string
}

