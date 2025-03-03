#vpc
resource "aws_vpc" "login-vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = var.vpc_tenancy

  tags = {
    Name = var.vpc_name
  }
}

# Public Subnets
resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.login-vpc.id
  for_each                = var.public_subent_cidrs
  cidr_block              = each.value
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.vpc_name}-${each.key}-subnet"
  }
}
