#vpc
resource "aws_vpc" "login_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "login_vpc"
  }
}